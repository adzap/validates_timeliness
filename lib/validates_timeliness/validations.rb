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

          # checks if date part is valid, enforcing days in a month unlike Time
          Date.new(*time_array[0..2])
          
          # checks if time part is valid and returns object
          Time.mktime(*time_array)
        rescue
          nil
        end
      end
            
      def validates_timeliness_of(*attr_names)
        configuration = { :on => :save, :type => :time, :allow_nil => false, :allow_blank => false }
        configuration.update(timeliness_default_error_messages)
        configuration.update(attr_names.extract_options!)
        
        # we need to check raw value for blank or nil in cases when an invalid value returns nil
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
                record.errors.add(attr_name, configuration[:invalid_date_message] % configuration[:type])
                next
              end
            end
            
            validate_timeliness_restrictions(record, attr_name, time, configuration)
          rescue
            record.send("#{attr_name}=", nil)
            record.errors.add(attr_name, configuration[:invalid_date_message] % configuration[:type])
            next
          end      
          
        end
      end   
      
      # Use this validation to force validation of values as Time
      def validates_time(*attr_names)
        configuration = attr_names.extract_options!
        configuration[:type] = :time
        validates_timeliness_of(attr_names, configuration)
      end
      
      # Use this validation to force validation of values as Date
      def validates_date(*attr_names)
        configuration = attr_names.extract_options!
        configuration[:type] = :date
        validates_timeliness_of(attr_names, configuration)
      end
      
      # Use this validation to force validation of values as DateTime
      def validates_datetime(*attr_names)
        configuration = attr_names.extract_options!
        configuration[:type] = :datetime
        validates_timeliness_of(attr_names, configuration)
      end
      
      private
      
      def validate_timeliness_restrictions(record, attr_name, value, configuration)
        restriction_methods = {:before => '<', :after => '>', :on_or_before => '<=', :on_or_after => '>='}
        
        conversion_method = "to_#{configuration[:type]}".to_sym
        time = value.send(conversion_method)
        
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
                else
                  timeliness_date_time_parse(restriction)
              end            
              
              next if compare.nil?
              compare = compare.send(conversion_method) if compare
              
              record.errors.add(attr_name, configuration["#{option}_message".to_sym] % compare) unless time.send(method, compare)
            rescue
              record.errors.add(attr_name, "restriction '#{option}' value was invalid")
            end
          end
        end
      end
      
      def timeliness_default_error_messages
        defaults = ActiveRecord::Errors.default_error_messages.slice(:blank, :invalid_date, :before, :on_or_before, :after, :on_or_after)
        returning({}) do |messages|
          defaults.each {|k, v| messages["#{k}_message".to_sym] = v }
        end
      end
                  
    end
  end
end
