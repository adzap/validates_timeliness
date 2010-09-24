module ValidatesTimeliness
  module AttributeMethods
    extend ActiveSupport::Concern

    module ClassMethods

      protected

      def define_timeliness_methods(before_type_cast=false)
        return if timeliness_validated_attributes.blank?
        timeliness_validated_attributes.each do |attr_name|
          define_timeliness_write_method(attr_name)
          define_timeliness_before_type_cast_method(attr_name) if before_type_cast
        end
      end

      def define_timeliness_write_method(attr_name)
        type = timeliness_attribute_type(attr_name)
        timezone_aware = timeliness_attribute_timezone_aware?(attr_name)

        method_body, line = <<-EOV, __LINE__ + 1
          def #{attr_name}=(value)
            @timeliness_cache ||= {}
            @timeliness_cache["#{attr_name}"] = value
            #{ "value = ValidatesTimeliness::Parser.parse(value, :#{type}, :timezone_aware => #{timezone_aware}) if value.is_a?(String)" if ValidatesTimeliness.use_plugin_parser }
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

      # Override in ORM shim
      def timeliness_attribute_timezone_aware?(attr_name)
        false
      end

      # Override in ORM shim
      def timeliness_attribute_type(attr_name)
        :datetime
      end

    end

    module InstanceMethods

      def _timeliness_raw_value_for(attr_name)
        @timeliness_cache && @timeliness_cache[attr_name.to_s]
      end

      def _clear_timeliness_cache
        @timeliness_cache = {}
      end

    end

  end
end
