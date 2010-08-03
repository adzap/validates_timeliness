module ValidatesTimeliness
  module Extensions
    module MultiparameterHandler
      extend ActiveSupport::Concern

      included do
        alias_method_chain :instantiate_time_object, :timeliness
      end

      private

      # Stricter handling of date and time values from multiparameter 
      # assignment from the date/time select view helpers
      #
      def instantiate_time_object_with_timeliness(name, values)
        unless Date.valid_civil?(*values[0..2])
          value =  [values[0], *values[1..2].map {|s| s.to_s.rjust(2,"0")} ].join("-")
          value += ' ' + values[3..5].map {|s| s.to_s.rjust(2, "0") }.join(":") unless values[3..5].empty?
          return value
        end

        if self.class.send(:create_time_zone_conversion_attribute?, name, column_for_attribute(name))
          Time.zone.local(*values)
        else
          Time.time_with_datetime_fallback(@@default_timezone, *values)
        end
      end

    end
  end
end
