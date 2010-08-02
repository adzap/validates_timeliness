module ValidatesTimeliness
  module Extensions
    module DateTimeSelect
      extend ActiveSupport::Concern

      # Intercepts the date and time select helpers to reuse the values from the
      # the params rather than the parsed value. This allows invalid date/time
      # values to be redisplayed instead of blanks to aid correction by the user.
      # Its a minor usability improvement which is rarely an issue for the user.

      included do
        alias_method_chain :datetime_selector, :timeliness
        alias_method_chain :value, :timeliness
      end

      module InstanceMethods

        TimelinessDateTime = Struct.new(:year, :month, :day, :hour, :min, :sec)

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

          values = [nil] * 6
          pairs.map do |(param, value)|
            position = param.scan(/\(([0-9]*).*\)/).first.first
            values[position.to_i-1] = value
          end

          TimelinessDateTime.new(*values)
        end
      end

    end
  end
end
