module ValidatesTimeliness
  module AttributeMethods
    extend ActiveSupport::Concern

    included do
      if attribute_method_matchers.any? {|m| m.suffix == "_before_type_cast" && m.prefix.blank? }
        extend BeforeTypeCastMethods
      end
    end

    module ClassMethods

      protected

      def define_method_attribute=(attr_name)
        if timeliness_validated_attributes.include?(attr_name)
          method_body, line = <<-EOV, __LINE__ + 1
            def #{attr_name}=(value)
              @attributes_cache ||= {}
              @attributes_cache["_#{attr_name}_before_type_cast"] = value
              super
            end
          EOV
          class_eval(method_body, __FILE__, line)
        else
          super
        end
      end

    end

    module BeforeTypeCastMethods

      def define_method_attribute_before_type_cast(attr_name)
        if timeliness_validated_attributes.include?(attr_name)
          method_body, line = <<-EOV, __LINE__ + 1
            def #{attr_name}_before_type_cast
              @attributes_cache && @attributes_cache["_#{attr_name}_before_type_cast"]
            end
          EOV
          class_eval(method_body, __FILE__, line)
        else
          super rescue(NoMethodError)
        end
      end

    end

  end
end
