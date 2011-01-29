module ConfigHelper
  # Justin French tip
  def with_config(preference_name, temporary_value)
    old_value = ValidatesTimeliness.send(preference_name)
    ValidatesTimeliness.send(:"#{preference_name}=", temporary_value)
    yield
  ensure
    ValidatesTimeliness.send(:"#{preference_name}=", old_value)
  end
end
