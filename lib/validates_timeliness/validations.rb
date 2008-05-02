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
          
          next if raw_value.is_nil? and options[:allow_nil]
          
          begin
            if raw_value.acts_like?(:time)
              time = raw_value
            else
              time_array = ParseDate.parsedate(raw_value)            

              # checks if date is valid and enforces number of days in a month unlike Time
              date = Date.new(*time_array[0..2])
              
              # checks if time is valid as it will accept bad date values
              time = Time.mktime(*time_array)
            end
            
            restriction_methods.each do |option, method|
              if restriction = options[option]
                restriction = restriction.to_time
                record.errors.add(attr_name, "must be #{humanize(option)} #{restriction}") unless time.send(method, restriction)
              end
            end
          rescue
            record.errors.add(attr_name, "is not a valid time")
            next
          end      
          
        end
      end
      
    end
    
  end
end
