module ValidatesTimeliness

  class DateTimeInvalid < StandardError; end

  module Validations    
        
    def self.included(base)
      base.extend ClassMethods
    end
    
    module ClassMethods

      def timeliness_date_time_parser(time)
        begin        
          if raw_value.acts_like?(:time) || raw_value.is_a?(Date)
            raw_value
          else
            time_array = ParseDate.parsedate(raw_value)            

            # checks if date is valid which enforces number of days in a month unlike Time
            Date.new(*time_array[0..2])
            
            # checks if time is valid and return object
            Time.mktime(*time_array)          
          end
        rescue
          raise ValidatesTimeliness::DateTimeInvalid
        end
      end
      
      def validates_timeliness_of(*attr_names)
        configuration = { :on => :save, :allow_nil => false, :allow_blank => false }
        configuration.update(attr_names.extract_options!)
        
        restriction_methods = {:before => '<', :after => '>', :on_or_before => '<=', :on_or_after => '>='}
        
        # we need to check raw value for blank or nil to catch when invalid value returns nil
        allow_nil   = configuration.delete(:allow_nil)
        allow_blank = configuration.delete(:allow_blank)
        
        validates_each(attr_names, configuration) do |record, attr_name, value|          
          raw_value = record.send("#{attr_name}_before_type_cast")

          next if (raw_value.nil? && allow_nil) || (raw_value.blank? && allow_blank)

          record.errors.add(attr_name, "can't be blank") and next if raw_value.blank?
          
          column = record.column_for_attribute(attr_name)
          begin
            time = timeliness_date_time_parser(raw_value)
            
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
                  
                  record.errors.add(attr_name, "must be #{option.to_s.humanize.downcase} #{compare}") unless time.send(method, compare)
                rescue
                  record.errors.add(attr_name, "restriction '#{option}' value was invalid")
                end
              end
            end
          rescue ValidatesTimeliness::DateTimeInvalid
            record.send("#{attr_name}=", nil)
            record.errors.add(attr_name, "is not a valid #{column.type}")
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
