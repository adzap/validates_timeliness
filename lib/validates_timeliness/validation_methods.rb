module ValidatesTimeliness
  module ValidationMethods

    # Error messages and error value formats added to AR defaults to allow 
    # global override.  
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods

      def parse_date_time(raw_value, type, strict=true)
        return nil if raw_value.blank?
        return raw_value if raw_value.acts_like?(:time) || raw_value.is_a?(Date)
        
        time_array = ValidatesTimeliness::Formats.parse(raw_value, type, strict)
        raise if time_array.nil?
        
        # Rails dummy time date part is defined as 2000-01-01
        time_array[0..2] = 2000, 1, 1 if type == :time
  
        # Date.new enforces days per month, unlike Time
        date = Date.new(*time_array[0..2]) unless type == :time
        
        return date if type == :date
        
        # Create time object which checks time part, and return time object
        make_time(time_array)
      rescue
        nil
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

      # The main validation method which can be used directly or called through
      # the other specific type validation methods
      def validates_timeliness_of(*attr_names)
        configuration = attr_names.extract_options!
        validator = ValidatesTimeliness::Validator.new(configuration)
        
        # bypass handling of allow_nil and allow_blank to validate raw value
        configuration.delete(:allow_nil)
        configuration.delete(:allow_blank)
        validates_each(attr_names, configuration) do |record, attr_name, value|
          raw_value = record.send("#{attr_name}_before_type_cast")
          validator.call(record, attr_name, raw_value)
          errors = validator.errors
          add_errors(record, attr_name, errors) unless errors.empty?
        end
      end

      # Time.zone. Rails 2.0 should be default_timezone.
      def make_time(time_array)
        if Time.respond_to?(:zone) && time_zone_aware_attributes
          Time.zone.local(*time_array)
        else
          begin
            Time.send(::ActiveRecord::Base.default_timezone, *time_array)
          rescue ArgumentError, TypeError
            zone_offset = ::ActiveRecord::Base.default_timezone == :local ? DateTime.local_offset : 0
            time_array.pop # remove microseconds
            DateTime.civil(*(time_array << zone_offset))
          end
        end
      end

      def add_errors(record, attr_name, errors)
        errors.each {|e| record.errors.add(attr_name, e) }
      end
    end

  end
end
