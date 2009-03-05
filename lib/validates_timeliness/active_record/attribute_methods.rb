module ValidatesTimeliness
  module ActiveRecord

    # Rails 2.1 removed the ability to retrieve the raw value of a time or datetime
    # attribute. The raw value is necessary to properly validate a string time or 
    # datetime value instead of the internal Rails type casting which is very limited 
    # and does not allow custom formats. These methods restore that ability while 
    # respecting the automatic timezone handling.
    #
    # The automatic timezone handling sets the assigned attribute value to the current
    # zone in Time.zone. To preserve this localised value and capture the raw value 
    # we cache the localised value on write and store the raw value in the attributes
    # hash for later retrieval and possibly validation. Any value from the database
    # will not be in the attribute cache on first read so will be considered in default
    # timezone and converted to local time. It is then stored back in the attributes
    # hash and cached to avoid the need for any subsequent differentiation.
    module AttributeMethods

      def self.included(base)
        base.extend ClassMethods
        base.class_eval do
          alias_method_chain :read_attribute, :timeliness
          class << self
            alias_method_chain :define_attribute_methods, :timeliness
          end
        end
      end

      # Adds check for cached date/time attributes which have been type cast already
      # and value can be used from cache. This prevents the raw date/time value from
      # being type cast using default Rails type casting when writing values
      # to the database.
      def read_attribute_with_timeliness(attr_name)
        attr_name = attr_name.to_s
        if !(value = @attributes[attr_name]).nil?
          column = column_for_attribute(attr_name)
          if column && [:date, :time, :datetime].include?(column.type) && @attributes_cache.has_key?(attr_name)
            return @attributes_cache[attr_name]
          end
        end
        read_attribute_without_timeliness(attr_name)
      end

      # If Rails dirty attributes is enabled then the value is added to
      # changed attributes if changed. Can't use the default dirty checking
      # implementation as it chains the write_attribute method which deletes
      # the attribute from the cache.
      def write_date_time_attribute(attr_name, value, type, time_zone_aware)
        new = self.class.parse_date_time(value, type)

        if new && type != :date
          new = new.to_time
          new = new.in_time_zone if time_zone_aware
        end

        if defined?(::ActiveRecord::Dirty) && !changed_attributes.include?(attr_name)
          old = read_attribute(attr_name)
          if old != new
            changed_attributes[attr_name] = (old.duplicable? ? old.clone : old)
          end
        end
        @attributes_cache[attr_name] = new
        @attributes[attr_name] = value
      end

      # If reloading then check if cached, which means its in local time.
      # If local, convert with parser as local timezone, otherwise use 
      # read_attribute method for quick default type cast of values from
      # database using default timezone.
      def read_date_time_attribute(attr_name, type, time_zone_aware, reload = false)
        cached = @attributes_cache[attr_name]
        return cached if @attributes_cache.has_key?(attr_name) && !reload

        if @attributes_cache.has_key?(attr_name)
          time = read_attribute_before_type_cast(attr_name)
          time = self.class.parse_date_time(time, type)
        else
          time = read_attribute(attr_name)
          @attributes[attr_name] = time && time_zone_aware ? time.in_time_zone : time
        end
        @attributes_cache[attr_name] = time && time_zone_aware ? time.in_time_zone : time
      end

      module ClassMethods

        # Define attribute reader and writer method for date, time and
        # datetime attributes to use plugin parser.
        def define_attribute_methods_with_timeliness
          return if generated_methods?
          columns_hash.each do |name, column|
            unless instance_method_already_implemented?(name)
              if [:date, :time, :datetime].include?(column.type)
                time_zone_aware = create_time_zone_conversion_attribute?(name, column) rescue false
                define_read_method_for_dates_and_times(name, column.type, time_zone_aware)
              end
            end

            unless instance_method_already_implemented?("#{name}=")
              if [:date, :time, :datetime].include?(column.type)
                time_zone_aware = create_time_zone_conversion_attribute?(name, column) rescue false
                define_write_method_for_dates_and_times(name, column.type, time_zone_aware)
              end
            end
          end
          define_attribute_methods_without_timeliness
        end

        # Define write method for date, time and datetime columns
        def define_write_method_for_dates_and_times(attr_name, type, time_zone_aware)
          method_body = <<-EOV
            def #{attr_name}=(value)
              write_date_time_attribute('#{attr_name}', value, #{type.inspect}, #{time_zone_aware})
            end
          EOV
          evaluate_attribute_method attr_name, method_body, "#{attr_name}="
        end

        def define_read_method_for_dates_and_times(attr_name, type, time_zone_aware)
          method_body = <<-EOV
            def #{attr_name}(reload = false)
              read_date_time_attribute('#{attr_name}', #{type.inspect}, #{time_zone_aware}, reload)
            end
          EOV
          evaluate_attribute_method attr_name, method_body
        end

      end

    end

  end
end

ActiveRecord::Base.send(:include, ValidatesTimeliness::ActiveRecord::AttributeMethods)
