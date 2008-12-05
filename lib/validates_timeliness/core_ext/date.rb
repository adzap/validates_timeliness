module ValidatesTimeliness
  module CoreExtensions
    module Date
    
      def to_dummy_time
        ::Time.send(ValidatesTimeliness.default_timezone, 2000, 1, 1, 0, 0, 0)
      end

    end
  end
end

Date.send(:include, ValidatesTimeliness::CoreExtensions::Date)
