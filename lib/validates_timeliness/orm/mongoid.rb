module ValidatesTimeliness
  module ORM
    module Mongoid
      extend ActiveSupport::Concern
      # You need define the fields before you define the validations.
      # It is best to use the plugin parser to avoid errors on a bad
      # field value in Mongoid. Parser will return nil rather than error.

      module ClassMethods 
        def timeliness_validation_for(attr_names, type)
          super
          attr_names.each { |attr_name| define_timeliness_write_method(attr_name, type, false) }
        end

        def define_timeliness_write_method(attr_name, type, timezone_aware)
          method_body, line = <<-EOV, __LINE__ + 1
            def #{attr_name}=(value)
              @attributes_cache ||= {}
              @attributes_cache["_#{attr_name}_before_type_cast"] = value
              #{ "value = ValidatesTimeliness::Parser.parse(value, :#{type}) if value.is_a?(String)" if ValidatesTimeliness.use_plugin_parser }
              write_attribute(:#{attr_name}, value)
            end
          EOV
          class_eval(method_body, __FILE__, line)
        end
      end
    end
  end
end
 
module Mongoid::Document
  include ValidatesTimeliness::HelperMethods
  include ValidatesTimeliness::AttributeMethods
  include ValidatesTimeliness::ORM::Mongoid
end
