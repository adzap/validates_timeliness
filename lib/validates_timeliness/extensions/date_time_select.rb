module ValidatesTimeliness
  module Extensions
    module DateTimeSelect
      extend ActiveSupport::Concern

      # Intercepts the date and time select helpers to reuse the values from
      # the params rather than the parsed value. This allows invalid date/time
      # values to be redisplayed instead of blanks to aid correction by the user.
      # It's a minor usability improvement which is rarely an issue for the user.

      included do
        alias_method_chain :datetime_selector, :timeliness
        alias_method_chain :value, :timeliness
      end

      class TimelinessDateTime
        attr_accessor :year, :month, :day, :hour, :min, :sec

        def initialize(year, month, day, hour, min, sec)
          @year, @month, @day, @hour, @min, @sec = year, month, day, hour, min, sec
        end

        # adapted from activesupport/lib/active_support/core_ext/date_time/calculations.rb, line 36 (3.0.7)
        def change(options)
          TimelinessDateTime.new(
            options[:year]  || year,
            options[:month] || month,
            options[:day]   || day,
            options[:hour]  || hour,
            options[:min]   || (options[:hour] ? 0 : min),
            options[:sec]   || ((options[:hour] || options[:min]) ? 0 : sec)
          )
        end
      end

      def datetime_selector_with_timeliness(*args)
        @timeliness_date_or_time_tag = true
        datetime_selector_without_timeliness(*args)
      end

      def value_with_timeliness(object)
        unless @timeliness_date_or_time_tag && @template_object.params[@object_name]
          return value_without_timeliness(object)
        end

        @template_object.params[@object_name]

        pairs = @template_object.params[@object_name].select {|k,v| k =~ /^#{@method_name}\(/ }
        return value_without_timeliness(object) if pairs.empty?

        values = [nil] * 6
        pairs.map do |(param, value)|
          position = param.scan(/\((\d+)\w+\)/).first.first
          values[position.to_i-1] = value.to_i
        end

        TimelinessDateTime.new(*values)
      end
    end
  end
end
