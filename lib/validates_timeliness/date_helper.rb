# This module intercepts the date and time select helpers to allow the 
# attribute value before type cast to be used as in the select helpers.
# This means that an invalid date or time will be redisplayed rather than the
# implicitly converted value which occurs by default with Rails.
module ValidatesTimeliness
  module DateHelper
    
    class InstanceTag      
      TimelinessDateTime = Struct.new(:year, :day, :month, :hour, :min, :sec)      
            
      def to_date_select_tag_with_timeliness(options = {}, html_options = {})
        @timeliness_date_or_time_tag = true
        date_or_time_select_without_timeliness(options.merge(:discard_hour => true), html_options)
      end
      alias_method_chain :to_date_select_tag, :timeliness

      def to_time_select_tag_with_timeliness(options = {}, html_options = {})
        @timeliness_date_or_time_tag = true
        date_or_time_select_without_timeliness(options.merge(:discard_year => true, :discard_month => true), html_options)
      end
      alias_method_chain :to_time_select_tag, :timeliness

      def to_datetime_select_tag_with_timeliness(options = {}, html_options = {})
        @timeliness_date_or_time_tag = true
        date_or_time_select_without_timeliness(options, html_options)
      end
      alias_method_chain :to_date_select_tag, :timeliness
    
      def value_with_timeliness(object)
        return value_without_timeliness(object) unless @timeliness_date_or_time_tag
        
        raw_value = value_before_type_case(object)
        
        if raw_value.acts_as?(:time) || raw_value.is_a?(Date)
          return value_without_timeliness(object)
        end
        
        time_array = ParseDate.parsedate(raw_value)
        
        TimelinessDateTime.new(time_array)        
      end      
      alias_method_chain :value, :timeliness
      
    end   
  end
end
