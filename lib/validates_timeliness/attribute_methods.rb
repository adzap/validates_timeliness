module ValidatesTimeliness

  # The crux of the plugin is being able to store user entered values as is, 
  # but also support Rails 2.1 automatic timezone conversion. This requires us 
  # to distinguish a user entered value from a raw value from the database 
  # because both maybe in string form, but only the database value should be 
  # converted to current local time zone. This is done by caching user entered 
  # values on write and storing the raw value in the attributes cache for later
  # retrieval. Any database read value will not be cached on first read so will
  # be converted to local timezone and then stored and cached to avoid the need
  # for any subsequent differentiation.
  #
  # A wholesale replacement of the Rails time type casting is not done to preserve
  # the quick conversion for timestamp columns and also any value which is never 
  # touched during the life of the record object.
  module AttributeMethods
    
    def self.included(base)
      base.extend ClassMethods
      if RAILS_VER <= '2.1'
        base.extend ClassMethodsOld
      end
    end
    
    def strict_time_type_cast(time)
      unless time.acts_like?(:time)
        # check for invalid date
        time.to_date rescue time = nil
        # convert to time if still valid. Check for pre Rails 2.1
        time = time && defined?(ActiveSupport::TimeWithZone) ? Time.zone.parse(time) : time.to_time rescue nil
      end
      time.respond_to?(:in_time_zone) ? time.in_time_zone : time rescue time
    end

    def read_attribute(attr_name)
      attr_name = attr_name.to_s
      if !(value = @attributes[attr_name]).nil?
        if column = column_for_attribute(attr_name)
          if unserializable_attribute?(attr_name, column)
            unserialize_attribute(attr_name)
          elsif column.klass == Time && @attributes_cache.has_key?(attr_name)          
            @attributes_cache[attr_name]
          else
            column.type_cast(value)
          end
        else
          value
        end
      else
        nil
      end
    end
    
    module ClassMethods
      
      # Define time attribute write r method to store time value as is without
      # conversion and then convert time with strict conversion and cache it.
      def define_write_method_for_time_zone_conversion(attr_name)
        method_body = <<-EOV
          def #{attr_name}=(time)
            @attributes['#{attr_name}'] = time
            unless time.acts_like?(:time)
              time = strict_time_type_cast(time)                
            end
            time = time.respond_to?(:in_time_zone) ? time.in_time_zone : time
            @attributes_cache['#{attr_name}'] = time
          end
        EOV
        evaluate_attribute_method attr_name, method_body, "#{attr_name}="
      end        
      
      # Define time attribute reader and do strict conversion. If reload then
      # then check if cached, which means its in local time. If local, do
      # strict type cast as local timezone, otherwise use read_attribute method 
      # for quick default type cast of values from database using default timezone. 
      def define_read_method_for_time_zone_conversion(attr_name)
        method_body = <<-EOV          
        def #{attr_name}(reload = false)
          cached = @attributes_cache['#{attr_name}']
          return cached if @attributes_cache.has_key?('#{attr_name}') && !reload
          if @attributes_cache.has_key?('#{attr_name}')
            time = read_attribute_before_type_cast('#{attr_name}')
            time = strict_time_type_cast(time)
          else
            time = read_attribute('#{attr_name}')
            @attributes['#{attr_name}'] = time.respond_to?(:in_time_zone) ? time.in_time_zone : time
          end
          @attributes_cache['#{attr_name}'] = time.respond_to?(:in_time_zone) ? time.in_time_zone : time
        end
        EOV
        evaluate_attribute_method attr_name, method_body
      end
      
    end
    
    # Rails < 2.1
    module ClassMethodsOld
      # Modified from AR to define Time attribute reader and writer methods with 
      # strict time type casting. Timezone conversion is ignored for pre Rails 2.1
      def define_attribute_methods
        return if generated_methods?
        columns_hash.each do |name, column|
          unless instance_method_already_implemented?(name)
            if self.serialized_attributes[name]
              define_read_method_for_serialized_attribute(name)
            elsif column.klass == Time
              define_read_method_for_time_zone_conversion(name.to_sym)
            else
              define_read_method(name.to_sym, name, column)
            end
          end

          unless instance_method_already_implemented?("#{name}=")
            if column.klass == Time
              define_write_method_for_time_zone_conversion(name.to_sym)
            else
              define_write_method(name.to_sym)
            end
          end

          unless instance_method_already_implemented?("#{name}?")
            define_question_method(name)
          end
        end
      end
    end

  end
end
