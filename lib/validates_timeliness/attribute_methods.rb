module ValidatesTimeliness
  module AttributeMethods
    extend ActiveSupport::Concern

    included do
      class_attribute :timeliness_validated_attributes
      self.timeliness_validated_attributes = []
    end

    module ClassMethods

      public
      # Override in ORM shim
      def timeliness_attribute_timezone_aware?(attr_name)
        false
      end

      # Override in ORM shim
      def timeliness_attribute_type(attr_name)
        :datetime
      end

      def undefine_attribute_methods
        super
        undefine_timeliness_attribute_methods
      end

      protected

      def define_timeliness_methods(before_type_cast=false)
        return if timeliness_validated_attributes.blank?
        timeliness_validated_attributes.each do |attr_name|
          define_attribute_timeliness_methods(attr_name, before_type_cast)
        end
      end

      def define_attribute_timeliness_methods(attr_name, before_type_cast=false)
        define_timeliness_write_method(attr_name)
        define_timeliness_before_type_cast_method(attr_name) if before_type_cast
      end

      def define_timeliness_write_method(attr_name)
        method_body, line = <<-EOV, __LINE__ + 1
          def #{attr_name}=(value)
            original_value = value
            @timeliness_cache ||= {}
            @timeliness_cache["#{attr_name}"] = original_value
            #{ "if value.is_a?(String)\n#{timeliness_type_cast_code(attr_name, 'value')}\nend" if ValidatesTimeliness.use_plugin_parser }
            
            super(value)
          end
        EOV
        generated_timeliness_methods.module_eval(method_body, __FILE__, line)
      end

      def define_timeliness_before_type_cast_method(attr_name)
        method_body, line = <<-EOV, __LINE__ + 1
          def #{attr_name}_before_type_cast
            _timeliness_raw_value_for('#{attr_name}') || @attributes['#{attr_name}']
          end
        EOV
        generated_timeliness_methods.module_eval(method_body, __FILE__, line)
      end

      def timeliness_type_cast_code(attr_name, var_name)
        type = timeliness_attribute_type(attr_name)
        timezone_aware = timeliness_attribute_timezone_aware?(attr_name)
        timezone = :current if timezone_aware

        "#{var_name} = Timeliness::Parser.parse(#{var_name}, :#{type}, :zone => #{timezone.inspect})"
      end

      def generated_timeliness_methods
        @generated_timeliness_methods ||= Module.new.tap { |m| include(m) }
      end

      def undefine_timeliness_attribute_methods
        generated_timeliness_methods.module_eval do
          instance_methods.each { |m| undef_method(m) }
        end
      end
    end

    def _timeliness_raw_value_for(attr_name)
      @timeliness_cache && @timeliness_cache[attr_name]
    end

    def _clear_timeliness_cache
      @timeliness_cache = {}
    end
  end
end
