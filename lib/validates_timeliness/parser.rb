module ValidatesTimeliness
  module Parser

    class << self

      def parse(raw_value, type, options={})
        return nil if raw_value.blank?
        return raw_value if raw_value.acts_like?(:time) || raw_value.is_a?(Date)
        
        time_array = ValidatesTimeliness::Formats.parse(raw_value, type, options.reverse_merge(:strict => true))
        return nil if time_array.nil?
        
        if type == :date
          Date.new(*time_array[0..2]) rescue nil
        else
          make_time(time_array[0..7])
        end
      end

      def make_time(time_array)
        # Enforce date part validity which Time class does not
        return nil unless Date.valid_civil?(*time_array[0..2])

        if Time.respond_to?(:zone) && ValidatesTimeliness.use_time_zones
          Time.zone.local(*time_array)
        else
          # Older AR way of handling times with datetime fallback
          begin
            time_zone = ValidatesTimeliness.default_timezone
            Time.send(time_zone, *time_array)
          rescue ArgumentError, TypeError
            zone_offset = time_zone == :local ? DateTime.local_offset : 0
            time_array.pop # remove microseconds
            DateTime.civil(*(time_array << zone_offset))
          end
        end
      rescue ArgumentError, TypeError
        nil
      end

    end

  end
end
