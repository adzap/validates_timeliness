module ValidatesTimeliness
  module AttributeMethods
    extend ActiveSupport::Concern

    module ClassMethods

      def define_timeliness_methods(before_type_cast=false)
        timeliness_validated_attributes.each do |attr_name, type|
          define_timeliness_write_method(attr_name, type, timeliness_attribute_timezone_aware?(attr_name))
          define_timeliness_before_type_cast_method(attr_name) if before_type_cast
        end
      end

      protected

      def define_timeliness_write_method(attr_name, type, timezone_aware)
        method_body, line = <<-EOV, __LINE__ + 1
          def #{attr_name}=(value)
            @attributes_cache ||= {}
            @attributes_cache["_#{attr_name}_before_type_cast"] = value
            #{ "value = ValidatesTimeliness::Parser.parse(value, :#{type}) if value.is_a?(String)" if ValidatesTimeliness.use_plugin_parser }
            super
          end
        EOV
        class_eval(method_body, __FILE__, line)
      end

      def define_timeliness_before_type_cast_method(attr_name)
        method_body, line = <<-EOV, __LINE__ + 1
          def #{attr_name}_before_type_cast
            _timeliness_raw_value_for('#{attr_name}')
          end
        EOV
        class_eval(method_body, __FILE__, line)
      end

      def timeliness_attribute_timezone_aware?(attr_name)
        false
      end

    end

    module InstanceMethods

      def _timeliness_raw_value_for(attr_name)
        @attributes_cache && @attributes_cache["_#{attr_name}_before_type_cast"]
      end

    end

  end
end
