module ValidatesTimeliness
  module Conversion

    def type_cast_value(value, type)
      return nil if value.nil? || !value.respond_to?(:to_time)

      value = value.in_time_zone if value.acts_like?(:time) && @timezone_aware
      value = case type
      when :time
        dummy_time(value)
      when :date
        value.to_date
      when :datetime
        value.is_a?(Time) ? value : value.to_time
      end
      if options[:ignore_usec] && value.is_a?(Time)
        Timeliness::Parser.make_time(Array(value).reverse[4..9], (:current if @timezone_aware))
      else
        value
      end
    end

    def dummy_time(value)
      time = if value.acts_like?(:time)
        value = value.in_time_zone if @timezone_aware
        [value.hour, value.min, value.sec]
      else
        [0,0,0]
      end
      values = ValidatesTimeliness.dummy_date_for_time_type + time
      Timeliness::Parser.make_time(values, (:current if @timezone_aware))
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
      return nil if value.nil?
      if ValidatesTimeliness.use_plugin_parser
        Timeliness::Parser.parse(value, @type, :zone => (:current if @timezone_aware), :format => options[:format], :strict => false)
      else
        @timezone_aware ? Time.zone.parse(value) : value.to_time(ValidatesTimeliness.default_timezone)
      end
    rescue ArgumentError, TypeError
      nil
    end

  end
end
