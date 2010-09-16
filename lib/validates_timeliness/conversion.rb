module ValidatesTimeliness
  module Conversion

    def type_cast_value(value, type)
      value = case type
      when :time
        dummy_time(value)
      when :date
        value.to_date
      when :datetime
        value.to_time
      end
    rescue
      nil
    end

    def dummy_time(value)
      time = if value.acts_like?(:time)
        [value.hour, value.min, value.sec]
      else
        [0,0,0]
      end
      Time.send(ValidatesTimeliness.default_timezone, *(ValidatesTimeliness.dummy_date_for_time_type + time))
    end

    def evaluate_option_value(value, record, timezone_aware=false)
      case value
      when Time
        timezone_aware ? value.in_time_zone : value
      when Date
        value
      when String
        if ValidatesTimeliness.use_plugin_parser
          ValidatesTimeliness::Parser.parse(value, :datetime, :timezone_aware => timezone_aware, :strict => false)
        else
          timezone_aware ? Time.zone.parse(value) : value.to_time(ValidatesTimeliness.default_timezone)
        end
      when Symbol
        if !record.respond_to?(value) && restriction_shorthand?(value)
          ValidatesTimeliness.restriction_shorthand_symbols[value].call
        else
          evaluate_option_value(record.send(value), record, timezone_aware)
        end
      when Proc
        result = value.arity > 0 ? value.call(record) : value.call
        evaluate_option_value(result, record, timezone_aware)
      else
        value
      end
    end

    def restriction_shorthand?(symbol)
      ValidatesTimeliness.restriction_shorthand_symbols.keys.include?(symbol)
    end

  end
end
