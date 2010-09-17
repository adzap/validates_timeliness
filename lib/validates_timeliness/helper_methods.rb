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
      def validates_timeliness_of(*attr_names)
        options = _merge_attributes(attr_names)
        attributes = options[:attributes].inject({}) {|validated, attr_name|
          attr_name = attr_name.to_s
          validated[attr_name] = options[:type]
          validated
        }
        self.timeliness_validated_attributes = attributes
        validates_with Validator, options
      end

      def validates_date(*attr_names)
        options = attr_names.extract_options!
        validates_timeliness_of *(attr_names << options.merge(:type => :date))
      end

      def validates_time(*attr_names)
        options = attr_names.extract_options!
        validates_timeliness_of *(attr_names << options.merge(:type => :time))
      end

      def validates_datetime(*attr_names)
        options = attr_names.extract_options!
        validates_timeliness_of *(attr_names << options.merge(:type => :datetime))
      end

    end
  end
end
