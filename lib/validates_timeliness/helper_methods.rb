module ValidatesTimeliness
  module HelperMethods
    extend ActiveSupport::Concern

    included do
      include ValidationMethods
      extend ValidationMethods
      class_inheritable_hash :timeliness_validated_attributes
      self.timeliness_validated_attributes = {}
    end

    module ValidationMethods
      def validates_date(*attr_names)
        timeliness_validation_for attr_names, :date
      end

      def validates_time(*attr_names)
        timeliness_validation_for attr_names, :time
      end

      def validates_datetime(*attr_names)
        timeliness_validation_for attr_names, :datetime
      end

      def timeliness_validation_for(attr_names, type)
        options = _merge_attributes(attr_names)
        options[:type] = type
        attributes = attr_names.inject({}) {|validated, attr_name|
          attr_name = attr_name.to_s
          validated[attr_name] = type
          validated
        }
        self.timeliness_validated_attributes = attributes
        validates_with Validator, options
      end

    end
  end
end
