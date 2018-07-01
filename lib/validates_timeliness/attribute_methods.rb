module ValidatesTimeliness
  module AttributeMethods
    extend ActiveSupport::Concern

    included do
      class_attribute :timeliness_validated_attributes
      self.timeliness_validated_attributes = []
    end
  end
end

ActiveModel::Type::Date.class_eval do
  # Module.new do |m|
    alias_method :_cast_value, :cast_value
    def cast_value(value)
      return _cast_value(value) unless ValidatesTimeliness.use_plugin_parser

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
  # end.tap { |mod| include mod }
end

ActiveModel::Type::Time.class_eval do
  def user_input_in_time_zone(value)
    if value.is_a?(String) && ValidatesTimeliness.use_plugin_parser
      dummy_time_value = value.sub(/\A(\d\d\d\d-\d\d-\d\d |)/, Date.current.to_s + ' ')
      Timeliness::Parser.parse(dummy_time_value, :datetime, zone: :current)
    else
      value.in_time_zone
    end
  end
end

ActiveModel::Type::DateTime.class_eval do
  def user_input_in_time_zone(value)
    if value.is_a?(String) && ValidatesTimeliness.use_plugin_parser
      Timeliness::Parser.parse(value, :datetime, zone: :current)
    else
      value.in_time_zone
    end
  end
end
