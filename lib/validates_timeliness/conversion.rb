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
    end

    def dummy_time(value)
      time = if value.acts_like?(:time)
        value = value.in_time_zone
        [value.hour, value.min, value.sec]
      else
        [0,0,0]
      end
      dummy_date = ValidatesTimeliness.dummy_date_for_time_type
      Time.local(*(dummy_date + time))
    end

  end
end
