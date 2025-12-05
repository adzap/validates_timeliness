module Timeliness
  class Configuration
    # Default timezone. Options:
    #   - :local (default)
    #   - :utc
    #   
    #   If ActiveSupport loaded, also
    #   - :current
    #   - 'Zone name'
    #
    attr_accessor :default_timezone 

    # Set the default date part for a time type values.
    #
    attr_accessor :date_for_time_type

    # Default parsing of ambiguous date formats. Options:
    #   - :us (default, 01/02/2000 = 2nd of January 2000)
    #   - :euro (01/02/2000 = 1st of February 2000)
    #
    attr_accessor :ambiguous_date_format

    # Set the threshold value for a two digit year to be considered last century
    #
    # Default: 30
    #
    #   Example:
    #     year = '29' is considered 2029
    #     year = '30' is considered 1930
    #
    attr_accessor :ambiguous_year_threshold

    def initialize
      @default_timezone = :local
      @date_for_time_type = lambda { Time.now }
      @ambiguous_date_format = :us
      @ambiguous_year_threshold = 30
    end
  end
end