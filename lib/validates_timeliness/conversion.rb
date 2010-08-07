module ValidatesTimeliness
  module Conversion

    def type_cast_value(value, type)
      value = case type
      when :time
        dummy_time(value)
      when :date
        value.to_date
      when :datetime
        value.to_time.in_time_zone
      end
    rescue
      nil
    end

    def dummy_time(value)
      time = if value.acts_like?(:time)
        value = value.in_time_zone
        [value.hour, value.min, value.sec]
      else
        [0,0,0]
      end
      Time.local(*(ValidatesTimeliness.dummy_date_for_time_type + time))
    end

    def evaluate_option_value(value, record)
      case value
      when Time, Date
        value
      when String
        value.to_time(:local)
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

  end
end
