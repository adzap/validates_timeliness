module ValidatesTimeliness
  module CoreExtensions
    module DateTime

      def to_dummy_time
        ::Time.send(ValidatesTimeliness.default_timezone, 2000, 1, 1, hour, min, sec)
      end

    end
  end
end

DateTime.send(:include, ValidatesTimeliness::CoreExtensions::DateTime)
