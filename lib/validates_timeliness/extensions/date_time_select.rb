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
      end

      module InstanceMethods

        TimelinessDateTime = Struct.new(:year, :month, :day, :hour, :min, :sec)

        def datetime_selector_with_timeliness(*args)
          @timeliness_date_or_time_tag = true
          datetime_selector_without_timeliness(*args)
        end

        def value(object)
          unless @timeliness_date_or_time_tag && @template_object.params[@object_name]
            return super
          end

          pairs = @template_object.params[@object_name].select {|k,v| k =~ /^#{@method_name}\(/ }
          return super if pairs.empty?

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
