module ValidatesTimeliness
  module ORM
    module ActiveRecord
      extend ActiveSupport::Concern

      module ClassMethods
        def define_attribute_methods
          super
          # Define write method and before_type_cast method
          define_timeliness_methods(true)
        end

        def timeliness_attribute_timezone_aware?(attr_name)
          attr_name = attr_name.to_s
          create_time_zone_conversion_attribute?(attr_name, columns_hash[attr_name])
        end

        def timeliness_attribute_type(attr_name)
          columns_hash[attr_name.to_s].type
        end

        def timeliness_type_cast_code(attr_name)
          type = timeliness_attribute_type(attr_name)
          timezone_aware = timeliness_attribute_timezone_aware?(attr_name)

          <<-END
          if value.is_a?(String)
            value = Timeliness::Parser.parse(value, :#{type}, :zone => (:current if #{timezone_aware}))
            value = value.to_date if value && :#{type} == :date
          end
          END
        end
      end

      module InstanceMethods
        def reload(*args)
          _clear_timeliness_cache
          super
        end
      end

    end
  end
end

class ActiveRecord::Base
  include ValidatesTimeliness::AttributeMethods
  include ValidatesTimeliness::ORM::ActiveRecord
end
