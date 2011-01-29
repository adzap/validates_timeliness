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
