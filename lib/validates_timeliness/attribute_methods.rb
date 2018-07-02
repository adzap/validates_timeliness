module ValidatesTimeliness
  module AttributeMethods
    extend ActiveSupport::Concern

    included do
      class_attribute :timeliness_validated_attributes
      self.timeliness_validated_attributes = []
    end
  end
end

ActiveModel::Type::Date.prepend Module.new {
  def cast_value(value)
    return super unless ValidatesTimeliness.use_plugin_parser

    if value.is_a?(::String)
      return if value.empty?
      value = Timeliness::Parser.parse(value, :date)
      value.to_date if value
    elsif value.respond_to?(:to_date)
      value.to_date
    else
      value
    end
  end
}

ActiveModel::Type::Time.prepend Module.new {
  def user_input_in_time_zone(value)
    return super unless ValidatesTimeliness.use_plugin_parser

    if value.is_a?(String)
      dummy_time_value = value.sub(/\A(\d\d\d\d-\d\d-\d\d |)/, Date.current.to_s + ' ')
      Timeliness::Parser.parse(dummy_time_value, :datetime, zone: :current)
    else
      value.in_time_zone
    end
  end
}

ActiveModel::Type::DateTime.prepend Module.new {
  def user_input_in_time_zone(value)
    if value.is_a?(String) && ValidatesTimeliness.use_plugin_parser
      Timeliness::Parser.parse(value, :datetime, zone: :current)
    else
      value.in_time_zone
    end
  end
}