module ConfigHelper
  extend ActiveSupport::Concern

  # Justin French tip
  def with_config(preference_name, temporary_value)
    old_value = ValidatesTimeliness.send(preference_name)
    ValidatesTimeliness.send(:"#{preference_name}=", temporary_value)
    yield
  ensure
    ValidatesTimeliness.send(:"#{preference_name}=", old_value)
  end

  def reset_validation_setup_for(model_class)
    model_class.reset_callbacks(:validate)
    model_class._validators.clear
    model_class.timeliness_validated_attributes = [] if model_class.respond_to?(:timeliness_validated_attributes)
    model_class.undefine_attribute_methods
    # This is a hack to avoid a disabled super method error message after an undef
    model_class.instance_variable_set(:@generated_attribute_methods, nil)
    model_class.instance_variable_set(:@generated_timeliness_methods, nil)
  end

  module ClassMethods
    def with_config(preference_name, temporary_value)
      original_config_value = ValidatesTimeliness.send(preference_name)

      before(:all) do
        ValidatesTimeliness.send(:"#{preference_name}=", temporary_value)
      end

      after(:all) do
        ValidatesTimeliness.send(:"#{preference_name}=", original_config_value)
      end
    end
  end
end
