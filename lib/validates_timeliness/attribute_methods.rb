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

      protected

      def define_attribute_timeliness_methods(attr_name, before_type_cast=false)
        define_timeliness_write_method(attr_name)
        define_timeliness_before_type_cast_method(attr_name) if before_type_cast
      end

      def define_timeliness_write_method(attr_name)
        generated_timeliness_methods.module_eval <<-STR, __FILE__, __LINE__ + 1
          def #{attr_name}=(value)
            write_timeliness_attribute('#{attr_name}', value)
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

    def write_timeliness_attribute(attr_name, value)
      @timeliness_cache ||= {}
      @timeliness_cache[attr_name] = value

      if ValidatesTimeliness.use_plugin_parser
        type = self.class.timeliness_attribute_type(attr_name)
        timezone = :current if self.class.timeliness_attribute_timezone_aware?(attr_name)
        value = Timeliness::Parser.parse(value, type, :zone => timezone)
        value = value.to_date if value && type == :date
      end

      @attributes[attr_name] = value
    end

    def read_timeliness_attribute_before_type_cast(attr_name)
      @timeliness_cache && @timeliness_cache[attr_name] || @attributes[attr_name]
    end

    def _clear_timeliness_cache
      @timeliness_cache = {}
    end
  end
end
