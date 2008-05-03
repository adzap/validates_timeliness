module ValidatesTimeliness
  module Validations
    
    def self.included(base)
      base.extend ClassMethods
    end
    
    module ClassMethods
    
      def validates_timeliness_of(*attr_names)
        # possible options only_date only_time only_epoch
        configuration = { :on => :save, :allow_nil => false }
        configuration.update(attr_names.extract_options!)
        
        restriction_methods = {:before => '<', :after => '>', :on_or_before => '<=', :on_or_after => '>='}
          
        validates_each(attr_names, configuration) do |record, attr_name, value|
          raw_value = record.send("#{attr_name}_before_type_cast") || value
          
          if raw_value.nil?
            record.errors.add(attr_name, "cant' be blank") unless configuration[:allow_nil]
            next
          end
          
          column = record.column_for_attribute(attr_name)
          begin
            time = if raw_value.acts_like?(:time)
              raw_value
            elsif raw_value.is_a?(Date)
              raw_value.to_time
            else
              time_array = ParseDate.parsedate(raw_value)            

              # checks if date is valid and enforces number of days in a month unlike Time
              date = Date.new(*time_array[0..2])
              
              # checks if time is valid as it will accept bad date values
              Time.mktime(*time_array)
            end
            
            restriction_methods.each do |option, method|
              if restriction = configuration[option]
                compare = case restriction
                  when Time, Date, DateTime
                    restriction.to_time
                  when Symbol
                    record.send(restriction).to_time
                  when Proc
                    restriction.call(record)
                end
                
                begin                  
                  record.errors.add(attr_name, "must be #{option.to_s.humanize.downcase} #{compare}") unless time.send(method, compare)
                rescue
                  record.errors.add(attr_name, "restriction '#{option}' value was invalid")
                end
              end
            end
          rescue
            record.send("#{attr_name}=", nil)
            record.errors.add(attr_name, "is not a valid #{column.type}")
            next
          end      
          
        end
      end
      
    end
    
  end
end
