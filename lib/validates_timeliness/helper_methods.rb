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
  end
end
