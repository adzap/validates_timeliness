module ValidatesTimeliness
  module HelperMethods
    extend ActiveSupport::Concern

    included do
      include ValidationMethods
      extend ValidationMethods
    end

    module ValidationMethods
      def validates_date(*attr_names)
        validates_with Validator, _merge_attributes(attr_names).merge(:type => :date)
      end

      def validates_time(*attr_names)
        validates_with Validator, _merge_attributes(attr_names).merge(:type => :time)
      end

      def validates_datetime(*attr_names)
        validates_with Validator, _merge_attributes(attr_names).merge(:type => :datetime)
      end
    end

    module ClassMethods
      def timeliness_validated_attributes
        @timeliness_validated_attributes ||= begin
          _validators.map do |attr_name, validators|
            attr_name.to_s if validators.any? {|v| v.is_a?(ValidatesTimeliness::Validator) }
          end.compact
        end
      end
    end
  end
end
