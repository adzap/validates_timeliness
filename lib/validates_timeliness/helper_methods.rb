module ActiveModel
  module Validations

    module HelperMethods
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
        validates_with TimelinessValidator, _merge_attributes(attr_names).merge(:type => type)
      end
    end

  end
end
