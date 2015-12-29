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

      def validates_timeliness_of(*attr_names)
        timeliness_validation_for attr_names
      end

      def timeliness_validation_for(attr_names, type=nil)
        options = _merge_attributes(attr_names)
        options.update(:type => type) if type
        validates_with TimelinessValidator, options
      end
    end

  end
end
