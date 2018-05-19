module ValidatesTimeliness
  module ORM
    module ActiveModel
      extend ActiveSupport::Concern

      module ClassMethods
        public

        def define_attribute_methods(*attr_names)
          super.tap { define_timeliness_methods }
        end

        def undefine_attribute_methods
          super.tap { undefine_timeliness_attribute_methods }
        end

        def define_timeliness_methods(before_type_cast=false)
          return if timeliness_validated_attributes.blank?
          timeliness_validated_attributes.each do |attr_name|
            define_attribute_timeliness_methods(attr_name, before_type_cast)
          end
        end

        def generated_timeliness_methods
          @generated_timeliness_methods ||= Module.new { |m|
            extend Mutex_m
          }.tap { |mod| include mod }
        end

        def undefine_timeliness_attribute_methods
          generated_timeliness_methods.module_eval do
            instance_methods.each { |m| undef_method(m) }
          end
        end

        def define_attribute_timeliness_methods(attr_name, before_type_cast=false)
          define_timeliness_write_method(attr_name)
          define_timeliness_before_type_cast_method(attr_name) if before_type_cast
        end

        def define_timeliness_write_method(attr_name)
          generated_timeliness_methods.module_eval <<-STR, __FILE__, __LINE__ + 1
            def #{attr_name}=(value)
              @timeliness_cache ||= {}
              @timeliness_cache['#{attr_name}'] = value

              @attributes['#{attr_name}'] = super
            end
          STR
        end

        def define_timeliness_before_type_cast_method(attr_name)
          generated_timeliness_methods.module_eval <<-STR, __FILE__, __LINE__ + 1
            def #{attr_name}_before_type_cast
              read_timeliness_attribute_before_type_cast('#{attr_name}')
            end
          STR
        end
      end

      def read_timeliness_attribute_before_type_cast(attr_name)
        @timeliness_cache && @timeliness_cache[attr_name] || @attributes[attr_name]
      end

      def _clear_timeliness_cache
        @timeliness_cache = {}
      end

    end
  end
end
