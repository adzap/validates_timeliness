module ValidatesTimeliness
  module ORM
    module ActiveRecord
      extend ActiveSupport::Concern

      def self.use_plugin_cache?
        ::ActiveRecord::VERSION::STRING < '3.1.0'
      end

      included do
        unless ValidatesTimeliness::ORM::ActiveRecord.use_plugin_cache? 
          # Just use the built-in before_type_cast retrieval
          alias_method :_timeliness_raw_value_for, :read_attribute_before_type_cast
        end
      end

      module ClassMethods
        def define_attribute_methods
          super
          use_before_type_cast = ValidatesTimeliness::ORM::ActiveRecord.use_plugin_cache?

          if use_before_type_cast || ValidatesTimeliness.use_plugin_parser
            define_timeliness_methods(use_before_type_cast)
          end
        end

        # ActiveRecord >= 3.1.x has correct before_type_cast implementation to support plugin, except parser
        unless ValidatesTimeliness::ORM::ActiveRecord.use_plugin_cache?
          def define_timeliness_write_method(attr_name)
            method_body, line = <<-EOV, __LINE__ + 1
              def #{attr_name}=(value)
                original_value = value
                if original_value.is_a?(String)\n#{timeliness_type_cast_code(attr_name, 'value')}\nend
                super(value)
                @attributes['#{attr_name}'] = original_value
              end
            EOV
            generated_timeliness_methods.module_eval(method_body, __FILE__, line)
          end
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

      # ActiveRecord >= 3.1.x needs no cached cleared
      if use_plugin_cache?
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
