module ValidatesTimeliness
  module Parser

    class << self

      def parse(raw_value, type, options={})
        return nil if raw_value.blank?
        return raw_value if raw_value.acts_like?(:time) || raw_value.is_a?(Date)
        
        options.reverse_merge!(:strict => true)

        time_array = ValidatesTimeliness::Formats.parse(raw_value, type, options)
        raise if time_array.nil?
        
        # Rails dummy time date part is defined as 2000-01-01
        time_array[0..2] = 2000, 1, 1 if type == :time
  
        # Date.new enforces days per month, unlike Time
        date = Date.new(*time_array[0..2]) unless type == :time
        
        return date if type == :date
        
        make_time(time_array[0..7])
      rescue
        nil
      end

      def make_time(time_array)
        if Time.respond_to?(:zone) && ValidatesTimeliness.use_time_zones
          Time.zone.local(*time_array)
        else
          begin
            time_zone = ValidatesTimeliness.default_timezone
            Time.send(time_zone, *time_array)
          rescue ArgumentError, TypeError
            zone_offset = time_zone == :local ? DateTime.local_offset : 0
            time_array.pop # remove microseconds
            DateTime.civil(*(time_array << zone_offset))
          end
        end
      end

    end

  end
end
