module ValidatesTimeliness
  module Conversion

    def type_cast_value(value, type)
      return nil if value.nil?

      value.in_time_zone if value.acts_like?(:time) && @timezone_aware
      value = case type
      when :time
        dummy_time(value)
      when :date
        value.to_date
      when :datetime
        value.to_time
      end
    end

    def dummy_time(value)
      time = if value.acts_like?(:time)
        [value.hour, value.min, value.sec]
      else
        [0,0,0]
      end
      values = ValidatesTimeliness.dummy_date_for_time_type + time
      @timezone_aware ? Time.zone.local(*values) : Time.send(ValidatesTimeliness.default_timezone, *values)
    end

    def evaluate_option_value(value, record)
      case value
      when Time, Date
        value
      when String
        parse(value)
      when Symbol
        if !record.respond_to?(value) && restriction_shorthand?(value)
          ValidatesTimeliness.restriction_shorthand_symbols[value].call
        else
          evaluate_option_value(record.send(value), record)
        end
      when Proc
        result = value.arity > 0 ? value.call(record) : value.call
        evaluate_option_value(result, record)
      else
        value
      end
    end

    def restriction_shorthand?(symbol)
      ValidatesTimeliness.restriction_shorthand_symbols.keys.include?(symbol)
    end

    def parse(value)
      if ValidatesTimeliness.use_plugin_parser
        ValidatesTimeliness::Parser.parse(value, @type, :timezone_aware => @timezone_aware, :strict => false)
      else
        @timezone_aware ? Time.zone.parse(value) : value.to_time(ValidatesTimeliness.default_timezone)
      end
    rescue ArgumentError, TypeError
      nil
    end

  end
end
