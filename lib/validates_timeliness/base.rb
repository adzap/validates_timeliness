module ValidatesTimeliness
  module Base
    
    def time_array_to_string(time_array)
      time_array.collect! {|i| i.to_s.rjust(2, '0') }
      time_array[0..2].join('-') + ' ' + time_array[3..5].join(':')
    end
  
    # Overrides AR method to store multiparameter time and dates 
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
            send(name + "=", value)
          rescue => ex
            errors << AttributeAssignmentError.new("error on assignment #{values.inspect} to #{name}", ex, name)
          end
        end
      end
      unless errors.empty?
        raise MultiparameterAssignmentErrors.new(errors), "#{errors.size} error(s) on assignment of multiparameter attributes"
      end
    end
    
    def strict_time_type_cast(time)
      if time.acts_like?(:time)
        time.respond_to?(:in_time_zone) ? time.time.in_time_zone : time
      else
        klass = ActiveRecord::ConnectionAdapters::Column
        # check for invalid date
        time = nil unless klass.string_to_date(time)
        # convert to time if still valid
        time = klass.string_to_time(time) if time
      end
    end
    
    def read_attribute(attr_name)
      attr_name = attr_name.to_s
      if !(value = @attributes[attr_name]).nil?
        if column = column_for_attribute(attr_name)
          if unserializable_attribute?(attr_name, column)
            unserialize_attribute(attr_name)
          elsif column.klass == Time
            strict_time_type_cast(value)
          else
            column.type_cast(value)
          end
        else
          value
        end
      else
        nil
      end
    end
    
  end
end
