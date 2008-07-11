module ValidatesTimeliness
  module MultiparameterAttributes
    
    def time_array_to_string(time_array)
      "%04d-%02d-%02d %02d:%02d:%02d" % time_array
    end
  
    # Overrides AR method to store multiparameter time and dates as 
    # ISO datetime string for later validation
    def execute_callstack_for_multiparameter_attributes(callstack)
      errors = []
      callstack.each do |name, values|
        klass = (self.class.reflect_on_aggregation(name.to_sym) || column_for_attribute(name)).klass
        if values.empty?
          send(name + "=", nil)
        else
          begin
            value = if Time == klass || Date == klass
              time_array_to_string(values)
            else
              klass.new(*values)              
            end
            send("#{name}=", value)
          rescue => ex
            errors << AttributeAssignmentError.new("error on assignment #{values.inspect} to #{name}", ex, name)
          end
        end
      end
      unless errors.empty?
        raise MultiparameterAssignmentErrors.new(errors), "#{errors.size} error(s) on assignment of multiparameter attributes"
      end
    end
    
  end
end
