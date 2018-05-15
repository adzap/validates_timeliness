module ValidatesTimeliness
  module Extensions
    module TimelinessDateTimeSelect
      # Intercepts the date and time select helpers to reuse the values from
      # the params rather than the parsed value. This allows invalid date/time
      # values to be redisplayed instead of blanks to aid correction by the user.
      # It's a minor usability improvement which is rarely an issue for the user.
      attr_accessor :object_name, :method_name, :template_object, :options, :html_options

      POSITION = {
        :year => 1, :month => 2, :day => 3, :hour => 4, :min => 5, :sec => 6
      }.freeze

      class DateTimeValue
        attr_accessor :year, :month, :day, :hour, :min, :sec

        def initialize(year:, month:, day: nil, hour: nil, min: nil, sec: nil)
          @year, @month, @day, @hour, @min, @sec = year, month, day, hour, min, sec
        end

        def change(options)
          self.class.new(
            year:  options.fetch(:year, year),
            month: options.fetch(:month, month),
            day:   options.fetch(:day, day),
            hour:  options.fetch(:hour, hour),
            min:   options.fetch(:min) { options[:hour] ? 0 : min },
            sec:   options.fetch(:sec) { options[:hour] || options[:min] ? 0 : sec }
          )
        end
      end

      # Splat args to support Rails 5.0 which expects object, and 5.2 which doesn't
      def value(*object)
        return super unless @template_object.params[@object_name]

        pairs = @template_object.params[@object_name].select {|k,v| k =~ /^#{@method_name}\(/ }
        return super if pairs.empty?

        values = {}
        pairs.each_pair do |key, value|
          position = key[/\((\d+)\w+\)/, 1]
          values[POSITION.key(position.to_i)] = value.to_i
        end

        DateTimeValue.new(values)
      end
    end
  end
end
