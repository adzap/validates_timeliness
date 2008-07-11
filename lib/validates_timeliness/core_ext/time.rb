module ValidatesTimeliness
  module CoreExtensions
    module Time 

      def to_dummy_time
        self.class.mktime(2000, 1, 1, hour, min, sec) 
      end

    end
  end
end
