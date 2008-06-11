module ValidatesTimeliness

  class DateTimeInvalid < StandardError; end

  module Validations    
        
    def self.included(base)
      base.extend ClassMethods
      
      error_messages = {
        :invalid_date => "is not a valid %s",
        :before       => "must be before %s",
        :on_or_before => "must be on or before %s",
        :after        => "must be after %s",
        :on_or_after  => "must be on or after %s"
      }
      
      ActiveRecord::Errors.default_error_messages.update(error_messages)
    end
    
    module ClassMethods      
      
      # Override this method to use any date parsing algorithm you like such as 
      # Chronic. Just return nil for an invalid value and a Time object for a 
      # valid parsed value.
      def timeliness_date_time_parse(raw_value)
        begin
          time_array = ParseDate.parsedate(raw_value)            

          # checks if date is valid which enforces number of days in a month unlike Time
          Date.new(*time_array[0..2])
          
          # checks if time part is valid and returns object
          Time.mktime(*time_array)
        rescue
          nil
        end
      end
      
      def timeliness_default_error_messages
        defaults = ActiveRecord::Errors.default_error_messages.slice(:blank, :invalid_date, :before, :on_or_before, :after, :on_or_after)
        returning({}) do |messages|
          defaults.each {|k, v| messages["#{k}_message".to_sym] = v }
        end
      end      
            
      def validates_timeliness_of(*attr_names)
        configuration = { :on => :save, :allow_nil => false, :allow_blank => false }
        configuration.update(timeliness_default_error_messages)
        configuration.update(attr_names.extract_options!)
        
        restriction_methods = {:before => '<', :after => '>', :on_or_before => '<=', :on_or_after => '>='}
        
        # we need to check raw value for blank or nil to catch when invalid value returns nil
        allow_nil   = configuration.delete(:allow_nil)
        allow_blank = configuration.delete(:allow_blank)
        
        validates_each(attr_names, configuration) do |record, attr_name, value|          
          raw_value = record.send("#{attr_name}_before_type_cast")

          next if (raw_value.nil? && allow_nil) || (raw_value.blank? && allow_blank)

          record.errors.add(attr_name, configuration[:blank_message]) and next if raw_value.blank?
          
          column = record.column_for_attribute(attr_name)
          begin
            if raw_value.acts_like?(:time) || raw_value.is_a?(Date)
              time = raw_value
            else
              unless time = timeliness_date_time_parse(raw_value)
                record.send("#{attr_name}=", nil)
                record.errors.add(attr_name, configuration[:invalid_date_message] % column.type)
                next
              end
            end
            
            conversion_method = column.type == :date ? :to_date : :to_time
            time = time.send(conversion_method)
            
            restriction_methods.each do |option, method|
              if restriction = configuration[option]
                begin
                  compare = case restriction
                    when Date
                      restriction
                    when Time, DateTime
                      restriction.respond_to?(:in_time_zone) ? restriction.in_time_zone : restriction
                    when Symbol
                      record.send(restriction)
                    when Proc
                      restriction.call(record)                  
                  end            
                  
                  next if compare.nil?
                  compare = compare.send(conversion_method) if compare
                  
                  record.errors.add(attr_name, configuration["#{option}_message".to_sym] % compare) unless time.send(method, compare)
                rescue
                  record.errors.add(attr_name, "restriction '#{option}' value was invalid")
                end
              end
            end
          rescue
            record.send("#{attr_name}=", nil)
            record.errors.add(attr_name, configuration[:invalid_date_message] % column.type)
            next
          end      
          
        end
      end   
      
      alias validates_times     validates_timeliness_of 
      alias validates_dates     validates_timeliness_of
      alias validates_datetimes validates_timeliness_of 
    end
    
  end
end
