module ValidatesTimeliness
  module ORM
    module ActiveRecord
      extend ActiveSupport::Concern

      def self.use_plugin_cache?
        ::ActiveRecord::VERSION::STRING < '3.1.0'
      end

      included do
        if ValidatesTimeliness::ORM::ActiveRecord.use_plugin_cache? 
          include Reload
        else
          # Just use the built-in before_type_cast retrieval
          alias_method :_timeliness_raw_value_for, :read_attribute_before_type_cast
        end
      end

      module ClassMethods
        public

        def timeliness_attribute_timezone_aware?(attr_name)
          attr_name = attr_name.to_s
          create_time_zone_conversion_attribute?(attr_name, columns_hash[attr_name])
        end

        def timeliness_attribute_type(attr_name)
          columns_hash[attr_name.to_s].type
        end

        def define_attribute_methods
          super.tap do |attribute_methods_generated|
            use_before_type_cast = ValidatesTimeliness::ORM::ActiveRecord.use_plugin_cache?
            define_timeliness_methods use_before_type_cast
          end
        end

        protected

        def define_attribute_timeliness_methods(attr_name, before_type_cast=false)
          if before_type_cast
            define_timeliness_write_method(attr_name)
            define_timeliness_before_type_cast_method(attr_name)
          elsif ValidatesTimeliness.use_plugin_parser
            define_timeliness_write_method_without_cache(attr_name)
          end
        end

        def define_timeliness_write_method_without_cache(attr_name)
          method_body, line = <<-EOV, __LINE__ + 1
            def #{attr_name}=(value)
              original_value = value
              if value.is_a?(String)\n#{timeliness_type_cast_code(attr_name, 'value')}\nend
              super(value)
              @attributes['#{attr_name}'] = original_value
            end
          EOV
          generated_timeliness_methods.module_eval(method_body, __FILE__, line)
        end

        def timeliness_type_cast_code(attr_name, var_name)
          type = timeliness_attribute_type(attr_name)

          method_body = super
          method_body << "\n#{var_name} = #{var_name}.to_date if #{var_name}" if type == :date
          method_body
        end
      end

      module Reload
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
