module ValidatesTimeliness
  module ValidationMethods

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

      def validates_time(*attr_names)
        configuration = attr_names.extract_options!
        configuration[:type] = :time
        validates_timeliness_of(attr_names, configuration)
      end
      
      def validates_date(*attr_names)
        configuration = attr_names.extract_options!
        configuration[:type] = :date
        validates_timeliness_of(attr_names, configuration)
      end
      
      def validates_datetime(*attr_names)
        configuration = attr_names.extract_options!
        configuration[:type] = :datetime
        validates_timeliness_of(attr_names, configuration)
      end

      private

      def validates_timeliness_of(attr_names, configuration)
        validator = ValidatesTimeliness::Validator.new(configuration.symbolize_keys)
        
        # bypass handling of allow_nil and allow_blank to validate raw value
        configuration.delete(:allow_nil)
        configuration.delete(:allow_blank)
        validates_each(attr_names, configuration) do |record, attr_name, value|
          validator.call(record, attr_name, value)
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

    end

  end
end

ActiveRecord::Base.send(:include, ValidatesTimeliness::ValidationMethods)
