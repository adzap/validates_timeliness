module ValidatesTimeliness

  # The crux of the plugin is being able to store raw user entered values, 
  # while not interferring with the Rails 2.1 automatic timezone handling. This
  # requires us to distinguish a user entered value from a value read from the 
  # database. Both maybe in string form, but only the database value should be 
  # interpreted as being in the default timezone which is normally UTC. The user
  # entered value should be interpreted as being in the current zone as indicated
  # by Time.zone.
  #
  # To do this we must cache the user entered values on write and store the raw 
  # value in the attributes hash for later retrieval and possibly validation. 
  # Any value from the database will not be in the attribute cache on first
  # read so will be considered in default timezone and converted to local time.
  # It is then stored back in the attributes hash and cached to avoid the need
  # for any subsequent differentiation.
  #
  # The wholesale replacement of the Rails time type casting is not done to 
  # preserve the quickest conversion for timestamp columns and also any value
  # which is never changed during the life of the record object.
  #
  # Dates are also handled but only write to cache value converted by plugin 
  # parser. Default read method will retrieve from cache or do default
  # conversion
  module AttributeMethods
    
    def self.included(base)
      base.extend ClassMethods
      
      if Rails::VERSION::STRING < '2.1'
        base.class_eval do
          class << self
            def create_time_zone_conversion_attribute?(name, column)
              false
            end
          end
        end
      end
    end
    
    # Adds check for cached time attributes which have been type cast already
    # and value can be used from cache. This prevents the raw time value from 
    # being type cast using default Rails type casting when writing values
    # to the database.
    def read_attribute(attr_name)
      attr_name = attr_name.to_s
      if !(value = @attributes[attr_name]).nil?
        if column = column_for_attribute(attr_name)
          if unserializable_attribute?(attr_name, column)
            unserialize_attribute(attr_name)
          elsif [:date, :time, :datetime].include?(column.type) && @attributes_cache.has_key?(attr_name)
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
    
      # Modified from AR to define Date and Time attribute reader and writer
      # methods with strict time type casting.
      def define_attribute_methods
        return if generated_methods?
        columns_hash.each do |name, column|
          unless instance_method_already_implemented?(name)
            if self.serialized_attributes[name]
              define_read_method_for_serialized_attribute(name)
            elsif create_time_zone_conversion_attribute?(name, column)
              define_read_method_for_time_zone_conversion(name.to_sym)
            else
              define_read_method(name.to_sym, name, column)
            end
          end

          unless instance_method_already_implemented?("#{name}=")
            if create_time_zone_conversion_attribute?(name, column)
              define_write_method_for_time_zone_conversion(name.to_sym)
            elsif [:date, :time, :datetime].include?(column.type)
              define_write_method_for_dates_and_times(name.to_sym, column.type)
            else
              define_write_method(name.to_sym)
            end
          end

          unless instance_method_already_implemented?("#{name}?")
            define_question_method(name)
          end
        end
      end
      
      # Define time attribute write method to store raw time value in 
      # attributes hash, then convert it with parser and cache it.
      #
      # If Rails 2.1 dirty attributes is enabled then the value is added to 
      # changed attributes if changed. Can't use the default dirty checking
      # implementation as it chains the write_attribute method which deletes
      # the attribute from the cache.
      def define_write_method_for_time_zone_conversion(attr_name)
        method_body = <<-EOV
          def #{attr_name}=(time)
            old = read_attribute('#{attr_name}') if defined?(ActiveRecord::Dirty)
            @attributes['#{attr_name}'] = time
            unless time.acts_like?(:time)
              time = self.class.parse_date_time(time, :datetime)
            end
            time = time.in_time_zone rescue nil
            if !changed_attributes.include?('#{attr_name}') && old != time
              changed_attributes['#{attr_name}'] = (old.duplicable? ? old.clone : old)
            end
            @attributes_cache['#{attr_name}'] = time
          end
        EOV
        evaluate_attribute_method attr_name, method_body, "#{attr_name}="
      end        
      
      # Define time attribute reader. If reloading then check if cached, 
      # which means its in local time. If local, convert with parser as local 
      # timezone, otherwise use read_attribute method for quick default type 
      # cast of values from database using default timezone. 
      def define_read_method_for_time_zone_conversion(attr_name)
        method_body = <<-EOV
          def #{attr_name}(reload = false)
            cached = @attributes_cache['#{attr_name}']
            return cached if @attributes_cache.has_key?('#{attr_name}') && !reload
            if @attributes_cache.has_key?('#{attr_name}')
              time = read_attribute_before_type_cast('#{attr_name}')
              time = self.class.parse_date_time(date, :datetime)
            else
              time = read_attribute('#{attr_name}')
              @attributes['#{attr_name}'] = time.in_time_zone rescue nil
            end
            @attributes_cache['#{attr_name}'] = time.in_time_zone rescue nil
          end
        EOV
        evaluate_attribute_method attr_name, method_body
      end
      
      # Define write for date and time columns or when time zone conversion is 
      # off. This is the default for Rails 2.0
      def define_write_method_for_dates_and_times(attr_name, type)
        method_body = <<-EOV
          def #{attr_name}=(value)
            @attributes_cache['#{attr_name}'] ||= self.class.parse_date_time(value, :#{type})
            @attributes['#{attr_name}'] = value
          end
        EOV
        evaluate_attribute_method attr_name, method_body
      end
      
    end

  end
end
