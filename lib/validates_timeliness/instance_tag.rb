module ValidatesTimeliness

  # Intercepts the date and time select helpers to allow the 
  # attribute value before type cast to be used as in the select helpers.
  # This means that an invalid date or time will be redisplayed rather than the
  # type cast value which would be nil if invalid.
  module InstanceTag    
  
    def self.included(base)
      base.alias_method_chain :date_or_time_select, :timeliness
      base.alias_method_chain :value, :timeliness      
    end
    
    TimelinessDateTime = Struct.new(:year, :month, :day, :hour, :min, :sec)      
      
    def date_or_time_select_with_timeliness(*args)
      @timeliness_date_or_time_tag = true
      date_or_time_select_without_timeliness(*args)
    end
  
    def value_with_timeliness(object)
      return value_without_timeliness(object) unless @timeliness_date_or_time_tag
      
      raw_value = value_before_type_cast(object)
      
      if raw_value.acts_like?(:time) || raw_value.is_a?(Date)
        return value_without_timeliness(object)
      end
      
      time_array = ParseDate.parsedate(raw_value)
      
      TimelinessDateTime.new(*time_array[0..5])
    end      
     
  end
end
