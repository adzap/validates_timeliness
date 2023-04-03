module ActiveModel
  module Validations

    module HelperMethods
      def validates_date(*attr_names)
        validates_with TimelinessValidator, _merge_attributes(attr_names).merge(type: :date)
      end

      def validates_time(*attr_names)
        validates_with TimelinessValidator, _merge_attributes(attr_names).merge(type: :time)
      end

      def validates_datetime(*attr_names)
        validates_with TimelinessValidator, _merge_attributes(attr_names).merge(type: :datetime)
      end

      def validates_timeliness_of(*attr_names)
        validates_with TimelinessValidator, _merge_attributes(attr_names)
      end
    end

  end
end
