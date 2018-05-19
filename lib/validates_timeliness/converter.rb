module ValidatesTimeliness
  class Converter
    attr_reader :type, :format, :ignore_usec

    def initialize(type:, format: nil, ignore_usec: false, time_zone_aware: false)
      @type = type
      @format = format
      @ignore_usec = ignore_usec
      @time_zone_aware = time_zone_aware
    end

    def type_cast_value(value)
      return nil if value.nil? || !value.respond_to?(:to_time)

      value = value.in_time_zone if value.acts_like?(:time) && time_zone_aware?
      value = case type
      when :time
        dummy_time(value)
      when :date
        value.to_date
      when :datetime
        value.is_a?(Time) ? value : value.to_time
      else
        value
      end
      if ignore_usec && value.is_a?(Time)
        Timeliness::Parser.make_time(Array(value).reverse[4..9], (:current if time_zone_aware?))
      else
        value
      end
    end

    def dummy_time(value)
      time = if value.acts_like?(:time)
        value = value.in_time_zone if time_zone_aware?
        [value.hour, value.min, value.sec]
      else
        [0,0,0]
      end
      values = ValidatesTimeliness.dummy_date_for_time_type + time
      Timeliness::Parser.make_time(values, (:current if time_zone_aware?))
    end

    def evaluate(value, scope=nil)
      case value
      when Time, Date
        value
      when String
        parse(value)
      when Symbol
        if !scope.respond_to?(value) && restriction_shorthand?(value)
          ValidatesTimeliness.restriction_shorthand_symbols[value].call
        else
          evaluate(scope.send(value))
        end
      when Proc
        result = value.arity > 0 ? value.call(scope) : value.call
        evaluate(result, scope)
      else
        value
      end
    end

    def restriction_shorthand?(symbol)
      ValidatesTimeliness.restriction_shorthand_symbols.keys.include?(symbol)
    end

    def parse(value)
      return nil if value.nil?

      if ValidatesTimeliness.use_plugin_parser
        Timeliness::Parser.parse(value, type, zone: (:current if time_zone_aware?), format: format, strict: false)
      else
        time_zone_aware? ? Time.zone.parse(value) : value.to_time(ValidatesTimeliness.default_timezone)
      end
    rescue ArgumentError, TypeError
      nil
    end

    def time_zone_aware?
      @time_zone_aware
    end
  end
end
