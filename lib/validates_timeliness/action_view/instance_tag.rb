module ValidatesTimeliness

  def self.enable_datetime_select_invalid_value_extension!
    ::ActionView::Helpers::InstanceTag.send(:include, ValidatesTimeliness::ActionView::InstanceTag)
  end

  module ActionView

    # Intercepts the date and time select helpers to allow the
    # attribute value before type cast to be used as in the select helpers.
    # This means that an invalid date or time will be redisplayed rather than the
    # type cast value which would be nil if invalid.
    #
    # Its a minor user experience improvement to be able to see original value
    # entered to aid correction.
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

      TimelinessDateTime = Struct.new(:year, :month, :day, :hour, :min, :sec)

      def datetime_selector_with_timeliness(*args)
        @timeliness_date_or_time_tag = true
        datetime_selector_without_timeliness(*args)
      end

      def value_with_timeliness(object)
        return value_without_timeliness(object) unless @timeliness_date_or_time_tag

        raw_value = value_before_type_cast(object)

        if raw_value.nil? || raw_value.acts_like?(:time) || raw_value.is_a?(Date)
          return value_without_timeliness(object)
        end

        date, time = raw_value.split(' ')
        date_array = date.split('-')
        time_array = time.split(':')

        TimelinessDateTime.new(*(date_array + time_array).map {|v| v.blank? ? nil : v.to_i})
      end

    end

  end
end
