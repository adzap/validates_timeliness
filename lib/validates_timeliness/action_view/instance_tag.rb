# TODO remove this from the plugin for v3.
module ValidatesTimeliness

  def self.enable_datetime_select_invalid_value_extension!
    ::ActionView::Helpers::InstanceTag.send(:include, ValidatesTimeliness::ActionView::InstanceTag)
  end

  module ActionView

    # Intercepts the date and time select helpers to reuse the values from the
    # the params rather than the parsed value. This allows invalid date/time
    # values to be redisplayed instead of blanks to aid correction by the user.
    # Its a minor usability improvement which is rarely an issue for the user.
    #
    module InstanceTag

      def self.included(base)
        selector_method = Rails::VERSION::STRING.to_f < 2.2 ? :date_or_time_select : :datetime_selector
        base.class_eval do
          alias_method :datetime_selector_without_timeliness, selector_method
          alias_method selector_method, :datetime_selector_with_timeliness
        end
        base.alias_method_chain :value, :timeliness
      end

class TimelinessDateTime

          attr_accessor :year, :month, :day, :hour, :min, :sec


          def initialize(year, month, day, hour, min, sec)

            @year  = year
            @month = month
            @day   = day
            @hour  = hour
            @min   = min
            @sec   = sec
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

        pairs = @template_object.params[@object_name].select {|k,v| k =~ /^#{@method_name}\(/ }
        return value_without_timeliness(object) if pairs.empty?

        values = pairs.map do |(param, value)|
          position = param.scan(/\(([0-9]*).*\)/).first.first
          [position, value.to_i]
        end.sort {|a,b| a[0] <=> b[0] }.map {|v| v[1] }

        TimelinessDateTime.new(*values)
      end

    end

  end
end
