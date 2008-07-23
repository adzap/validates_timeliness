module ValidatesTimeliness
  module MultiparameterAttributes
    
    def self.included(base)
      base.alias_method_chain :execute_callstack_for_multiparameter_attributes, :timeliness
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
        raise ActiveRecord::MultiparameterAssignmentErrors.new(errors), "#{errors.size} error(s) on assignment of multiparameter attributes"
      end
    end
    
    def time_array_to_string(values, type)
      values = values.map(&:to_s)
              
      case type
        when :date
          extract_date_from_multiparameter_attributes(values)
        when :time
          extract_time_from_multiparameter_attributes(values)
        when :datetime
          date_values, time_values = values.slice!(0, 3), values
          extract_date_from_multiparameter_attributes(date_values) + " " + extract_time_from_multiparameter_attributes(time_values)
      end
    end   
       
    def extract_date_from_multiparameter_attributes(values)
      [values[0], *values.slice(1, 2).map { |s| s.rjust(2, "0") }].join("-")
    end
    
    def extract_time_from_multiparameter_attributes(values)
      values.last(3).map { |s| s.rjust(2, "0") }.join(":")
    end
    
  end
end
