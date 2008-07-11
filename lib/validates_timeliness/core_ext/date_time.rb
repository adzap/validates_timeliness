module ValidatesTimeliness
  module CoreExtensions
    module DateTime

      def to_dummy_time
        ::Time.mktime(2000, 1, 1, hour, min, sec) 
      end

    end
  end
end
