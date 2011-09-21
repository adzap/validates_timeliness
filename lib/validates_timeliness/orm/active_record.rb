module ValidatesTimeliness
  module ORM
    module ActiveRecord
      extend ActiveSupport::Concern

      module ClassMethods
        def define_attribute_methods
          super
          # Define write method and before_type_cast method
          use_before_type_cast = ::ActiveRecord::VERSION::STRING < '3.1.0'
          define_timeliness_methods(use_before_type_cast)
        end

        def timeliness_attribute_timezone_aware?(attr_name)
          attr_name = attr_name.to_s
          create_time_zone_conversion_attribute?(attr_name, columns_hash[attr_name])
        end

        def timeliness_attribute_type(attr_name)
          columns_hash[attr_name.to_s].type
        end

        def timeliness_type_cast_code(attr_name, var_name)
          type = timeliness_attribute_type(attr_name)

          <<-END
            #{super}
            #{var_name} = #{var_name}.to_date if #{var_name} && :#{type} == :date
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
