module ValidatesTimeliness
  module CoreExtensions
    module Date
    
      def to_dummy_time
        ::Time.mktime(2000, 1, 1, 0, 0, 0)
      end

    end
  end
end
