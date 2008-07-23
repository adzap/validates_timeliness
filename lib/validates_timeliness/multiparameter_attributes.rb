module ValidatesTimeliness
  module MultiparameterAttributes
    
    def self.included(base)
      base.alias_method_chain :execute_callstack_for_multiparameter_attributes, :timeliness
    end    
        
    def time_array_to_string(time_array, type)
      case type
        when :time
          "%02d:%02d:%02d" % time_array[3..5]
        when :date
          "%04d-%02d-%02d" % time_array[0..2]
        when :datetime
          "%04d-%02d-%02d %02d:%02d:%02d" % time_array
       end
    end
  
    # Overrides AR method to store multiparameter time and dates as string
    # allowing validation later.
    def execute_callstack_for_multiparameter_attributes_with_timeliness(callstack)
      errors = []
      callstack.each do |name, values|
        klass = (self.class.reflect_on_aggregation(name.to_sym) || column_for_attribute(name)).klass
        if values.empty?
          send(name + "=", nil)
        else
          column = column_for_attribute(name)
          begin
            value = if [:date, :time, :datetime].include?(column.type)
              time_array_to_string(values, column.type)
            else
              klass.new(*values)
            end
            send(name + "=", value)
          rescue => ex
            errors << ActiveRecord::AttributeAssignmentError.new("error on assignment #{values.inspect} to #{name}", ex, name)
          end
        end
      end
      unless errors.empty?
        puts errors.inspect
        raise ActiveRecord::MultiparameterAssignmentErrors.new(errors), "#{errors.size} error(s) on assignment of multiparameter attributes"
      end
    end
    
  end
end
