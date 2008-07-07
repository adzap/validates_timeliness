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
  # Any database originating value will not be in the attribute cache on first
  # read so will be considered in UTC time and then converted to local time
  # and then stored back in the attributes hash and cached to avoid the need
  # for any subsequent differentiation.
  #
  # The wholesale replacement of the Rails time type casting is not done to 
  # preserve the quick conversion for timestamp columns and also any value which
  # is never touched during the life of the record object.
  module AttributeMethods
    
    def self.included(base)
      base.extend ClassMethods
      if Rails::VERSION::STRING <= '2.1'
        base.class_eval do 
          class << self
            alias_method :define_read_method_for_time,  :define_read_method_for_time_zone_conversion 
            alias_method :define_write_method_for_time, :define_write_method_for_time_zone_conversion 
          end
        end
        base.extend ClassMethodsOld
      end
    end

    # Does strict time type cast checking for Rails 2.1 timezone handling    
    def strict_time_type_cast(time)
      unless time.acts_like?(:time)
        time = self.class.timeliness_date_time_parse(time)
      end
      time_in_time_zone(time)
    end
    
    # Handles timezone shift if Rails 2.1
    def time_in_time_zone(time)
      time.respond_to?(:in_time_zone) ? time.in_time_zone : time
    end
    
    # Adds check for cached time attributes which have been type cast already
    # and value can be used from cache. This prevents the raw time value
    # from being type cast using default Rails type casting.
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
      
      # Define time attribute write method to store time value as is without
      # conversion and then convert time with strict conversion and cache it.
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
              time = strict_time_type_cast(time)
            end
            time = time_in_time_zone(time)
            if defined?(ActiveRecord::Dirty) && !changed_attributes.include?('#{attr_name}') && old != time
              changed_attributes['#{attr_name}'] = (old.duplicable? ? old.clone : old)
            end
            @attributes_cache['#{attr_name}'] = time
          end
        EOV
        evaluate_attribute_method attr_name, method_body, "#{attr_name}="
      end        
      
      # Define time attribute reader. If passed reload then check if cached, 
      # which means its in local time. If local, do strict type cast as local 
      # timezone, otherwise use read_attribute method for quick default type 
      # cast of values from database using default timezone. 
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
            @attributes['#{attr_name}'] = time_in_time_zone(time)
          end
          @attributes_cache['#{attr_name}'] = time_in_time_zone(time)
        end
        EOV
        evaluate_attribute_method attr_name, method_body
      end
      
    end
    
    # Only for Rails 2.0.x. Checks for time attributes to define special reader
    # and writer methods.
    module ClassMethodsOld
   
      # Modified from AR to define Time attribute reader and writer methods with 
      # strict time type casting.
      def define_attribute_methods
        return if generated_methods?
        columns_hash.each do |name, column|
          unless instance_method_already_implemented?(name)
            if self.serialized_attributes[name]
              define_read_method_for_serialized_attribute(name)
            elsif column.klass == Time
              define_read_method_for_time(name.to_sym)
            else
              define_read_method(name.to_sym, name, column)
            end
          end

          unless instance_method_already_implemented?("#{name}=")
            if column.klass == Time
              define_write_method_for_time(name.to_sym)
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
