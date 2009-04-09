module ValidatesTimeliness
  module ValidationMethods

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods

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

    end

  end
end

ActiveRecord::Base.send(:include, ValidatesTimeliness::ValidationMethods)
