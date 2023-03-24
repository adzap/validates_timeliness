module ValidatesTimeliness
  module ORM
    module ActiveModel
      extend ActiveSupport::Concern

      module ClassMethods
        public

        # Hook into bulk method definitions for non-attribute based methods validated.
        def define_attribute_methods(*attr_names)
          super.tap {
            define_timeliness_methods
          }
        end

        # Called when `attribute` methods is called and the timeliness overrides are defined here
        def define_attribute_method(attr_name)
          super.tap {
            define_attribute_timeliness_methods(attr_name)
          }
        end

        def undefine_attribute_methods
          super.tap {
            undefine_timeliness_attribute_methods
          }
        end

        def define_timeliness_methods(before_type_cast=false)
          return if timeliness_validated_attributes.blank?

          timeliness_validated_attributes.each do |attr_name|
            unless timeliness_method_already_implemented?(attr_name)
              define_attribute_timeliness_methods(attr_name, before_type_cast)
            end
          end
        end

        def define_timeliness_method(attr_name, before_type_cast=false)
          define_attribute_timeliness_methods(attr_name, before_type_cast)
        end

        # Lazy instantiate module as container of timeliness methods included in the model
        def generated_timeliness_methods
          @generated_timeliness_methods ||= Module.new { |m|
            extend Mutex_m
          }.tap { |mod| include mod }
        end

        def timeliness_method_already_implemented?(method_name)
          generated_timeliness_methods.method_defined?(method_name)
        end

        def undefine_timeliness_attribute_methods
          generated_timeliness_methods.module_eval do
            undef_method(*instance_methods)
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

              super
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
        @timeliness_cache && @timeliness_cache[attr_name] || @attributes[attr_name].value_before_type_cast
      end

      def _clear_timeliness_cache
        @timeliness_cache = {}
      end

    end
  end
end
