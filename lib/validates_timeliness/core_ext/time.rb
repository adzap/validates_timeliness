module ValidatesTimeliness
  module CoreExtensions
    module Time 

      def to_dummy_time
        self.class.send(ValidatesTimeliness.default_timezone, 2000, 1, 1, hour, min, sec) 
      end

    end
  end
end

Time.send(:include, ValidatesTimeliness::CoreExtensions::Time)
