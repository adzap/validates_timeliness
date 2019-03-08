module ValidatesTimeliness
  module ORM
    module ActiveRecord
      extend ActiveSupport::Concern

      def read_timeliness_attribute_before_type_cast(attr_name)
        read_attribute_before_type_cast(attr_name)
      end

    end
  end
end

ActiveSupport.on_load(:active_record) do
  include ValidatesTimeliness::AttributeMethods
  include ValidatesTimeliness::ORM::ActiveRecord
end
