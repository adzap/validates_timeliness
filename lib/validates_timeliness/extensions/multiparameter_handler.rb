module ValidatesTimeliness
  module Extensions
    module MultiparameterHandler
      extend ActiveSupport::Concern

      # Stricter handling of date and time values from multiparameter 
      # assignment from the date/time select view helpers

      included do
        alias_method_chain :instantiate_time_object, :timeliness
        alias_method :execute_callstack_for_multiparameter_attributes, :execute_callstack_for_multiparameter_attributes_with_timeliness
        alias_method :read_value_from_parameter, :read_value_from_parameter_with_timeliness
      end

      private

      def invalid_multiparameter_date_or_time_as_string(values)
        value =  [values[0], *values[1..2].map {|s| s.to_s.rjust(2,"0")} ].join("-")
        value += ' ' + values[3..5].map {|s| s.to_s.rjust(2, "0") }.join(":") unless values[3..5].empty?
        value
      end

      def instantiate_time_object_with_timeliness(name, values)
        validate_multiparameter_date_values(values) {
          instantiate_time_object_without_timeliness(name, values)
        }
      end

      def instantiate_date_object(name, values)
        validate_multiparameter_date_values(values) {
          Date.new(*values)
        }
      end

      # Yield if date values are valid
      def validate_multiparameter_date_values(values)
        if values[0..2].all?{ |v| v.present? } && Date.valid_civil?(*values[0..2])
          yield
        else
          invalid_multiparameter_date_or_time_as_string(values)
        end
      end

      def read_value_from_parameter_with_timeliness(name, values_from_param)
        klass = (self.class.reflect_on_aggregation(name.to_sym) || column_for_attribute(name)).klass
        values = values_from_param.is_a?(Hash) ? values_from_param.to_a.sort_by(&:first).map(&:last) : values_from_param

        if values.empty? || values.all?{ |v| v.nil? }
          nil
        elsif klass == Time
          instantiate_time_object(name, values)
        elsif klass == Date
          instantiate_date_object(name, values)
        else
          if respond_to?(:read_other_parameter_value)
            read_date_parameter_value(name, values_from_param)
          else
            klass.new(*values)
          end
        end
      end

      def execute_callstack_for_multiparameter_attributes_with_timeliness(callstack)
        errors = []
        callstack.each do |name, values_with_empty_parameters|
          begin
            send(name + "=", read_value_from_parameter(name, values_with_empty_parameters))
          rescue => ex
            values = values_with_empty_parameters.is_a?(Hash) ? values_with_empty_parameters.values : values_with_empty_parameters 
            errors << ActiveRecord::AttributeAssignmentError.new("error on assignment #{values.inspect} to #{name}", ex, name)
          end
        end
        unless errors.empty?
          raise ActiveRecord::MultiparameterAssignmentErrors.new(errors), "#{errors.size} error(s) on assignment of multiparameter attributes"
        end
      end

    end
  end
end
