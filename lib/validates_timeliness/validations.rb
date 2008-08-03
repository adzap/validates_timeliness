module ValidatesTimeliness
  # Adds ActiveRecord validation methods for date, time and datetime validation.
  # The validity of values can be restricted to be before or after certain dates
  # or times.
  module Validations    
        
    # Error messages and error value formats added to AR defaults to allow 
    # global override.  
    def self.included(base)
      base.extend ClassMethods
      
      base.class_inheritable_accessor :ignore_datetime_restriction_errors
      base.ignore_datetime_restriction_errors = false
      
      ActiveRecord::Errors.class_inheritable_accessor :date_time_error_value_formats
      ActiveRecord::Errors.date_time_error_value_formats = {
        :time     => '%H:%M:%S',
        :date     => '%Y-%m-%d',
        :datetime => '%Y-%m-%d %H:%M:%S'
      }      
      
      ActiveRecord::Errors.default_error_messages.update(
        :invalid_date     => "is not a valid date",
        :invalid_time     => "is not a valid time",
        :invalid_datetime => "is not a valid datetime",
        :before           => "must be before %s",
        :on_or_before     => "must be on or before %s",
        :after            => "must be after %s",
        :on_or_after      => "must be on or after %s"
      )
    end
    
    module ClassMethods
      
      def parse_date_time(raw_value, type, strict=true)
        return nil if raw_value.blank?
        return raw_value.to_time if raw_value.acts_like?(:time) || raw_value.is_a?(Date)
        
        time_array = ValidatesTimeliness::Formats.parse(raw_value, type, strict)
        raise if time_array.nil?
        
        # Rails dummy time date part is defined as 2000-01-01
        time_array[0..2] = 2000, 1, 1 if type == :time
  
        # Date.new enforces days per month, unlike Time
        Date.new(*time_array[0..2]) unless type == :time
        
        # Create time object which checks time part, and return time object
        make_time(time_array)
      rescue
        nil
      end
      
      # The main validation method which can be used directly or called through
      # the other specific type validation methods.      
      def validates_timeliness_of(*attr_names)
        configuration = { :on => :save, :type => :datetime, :allow_nil => false, :allow_blank => false }
        configuration.update(timeliness_default_error_messages)
        configuration.update(attr_names.extract_options!)
        
        # we need to check raw value for blank or nil
        allow_nil   = configuration.delete(:allow_nil)
        allow_blank = configuration.delete(:allow_blank)
        
        validates_each(attr_names, configuration) do |record, attr_name, value|          
          raw_value = record.send("#{attr_name}_before_type_cast")

          next if (raw_value.nil? && allow_nil) || (raw_value.blank? && allow_blank)

          record.errors.add(attr_name, configuration[:blank_message]) and next if raw_value.blank?
          
          column = record.column_for_attribute(attr_name)
          begin
            unless time = parse_date_time(raw_value, configuration[:type])
              record.errors.add(attr_name, configuration["invalid_#{configuration[:type]}_message".to_sym])
              next
            end
           
            validate_timeliness_restrictions(record, attr_name, time, configuration)
          rescue Exception => e
            record.errors.add(attr_name, configuration["invalid_#{configuration[:type]}_message".to_sym])
          end          
        end
      end   
      
      # Use this validation to force validation of values and restrictions 
      # as dummy time
      def validates_time(*attr_names)
        configuration = attr_names.extract_options!
        configuration[:type] = :time
        validates_timeliness_of(attr_names, configuration)
      end
      
      # Use this validation to force validation of values and restrictions 
      # as Date
      def validates_date(*attr_names)
        configuration = attr_names.extract_options!
        configuration[:type] = :date
        validates_timeliness_of(attr_names, configuration)
      end
      
      # Use this validation to force validation of values and restrictions
      # as Time/DateTime
      def validates_datetime(*attr_names)
        configuration = attr_names.extract_options!
        configuration[:type] = :datetime
        validates_timeliness_of(attr_names, configuration)
      end
      
     private
     
      def timeliness_restriction_value(restriction, record, type)
        case restriction
          when Time, Date, DateTime
            restriction
          when Symbol
            timeliness_restriction_value(record.send(restriction), record, type)
          when Proc
            timeliness_restriction_value(restriction.call(record), record, type)
          else
            parse_date_time(restriction, type, false)
        end
      end
      
      def restriction_type_cast_method(type)
        case type
          when :time     then :to_dummy_time
          when :date     then :to_date
          when :datetime then :to_time
        end
      end
      
      # Validate value against the temporal restrictions. Restriction values 
      # maybe of mixed type, so they are evaluated as a common type, which may
      # require conversion. The type used is defined by validation type.
      def validate_timeliness_restrictions(record, attr_name, value, configuration)
        restriction_methods = {:before => '<', :after => '>', :on_or_before => '<=', :on_or_after => '>='}
        
        type_cast_method = restriction_type_cast_method(configuration[:type])
        
        display = ActiveRecord::Errors.date_time_error_value_formats[configuration[:type]]
        
        value = value.send(type_cast_method)
        
        restriction_methods.each do |option, method|
          next unless restriction = configuration[option]
          begin
            compare = timeliness_restriction_value(restriction, record, configuration[:type])
            
            next if compare.nil?
            
            compare = compare.send(type_cast_method)
            record.errors.add(attr_name, configuration["#{option}_message".to_sym] % compare.strftime(display)) unless value.send(method, compare)
          rescue
            record.errors.add(attr_name, "restriction '#{option}' value was invalid") unless self.ignore_datetime_restriction_errors
          end
        end
      end
      
      # Map error message keys to *_message to merge with validation options
      def timeliness_default_error_messages
        defaults = ActiveRecord::Errors.default_error_messages.slice(
          :blank, :invalid_date, :invalid_time, :invalid_datetime, :before, :on_or_before, :after, :on_or_after)
        returning({}) do |messages|
          defaults.each {|k, v| messages["#{k}_message".to_sym] = v }
        end
      end
      
      # Create time in correct timezone. For Rails 2.1 that is value in 
      # Time.zone. Rails 2.0 should be default_timezone.
      def make_time(time_array)
        if Time.respond_to?(:zone) && time_zone_aware_attributes
          Time.zone.local(*time_array)
        else
          begin
            Time.send(ActiveRecord::Base.default_timezone, *time_array)
          rescue ArgumentError, TypeError
            zone_offset = ActiveRecord::Base.default_timezone == :local ? DateTime.local_offset : 0
            time_array.pop # remove microseconds
            DateTime.civil(*(time_array << zone_offset))
          end
        end
      end
                        
    end
  end
end
