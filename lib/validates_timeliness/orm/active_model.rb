module ValidatesTimeliness
  module ORM
    module ActiveModel
      extend ActiveSupport::Concern

      def read_timeliness_attribute_before_type_cast(attr_name)
        @attributes[attr_name].value_before_type_cast
      end

    end
  end
end
