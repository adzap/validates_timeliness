module ValidatesTimeliness
  module Extensions
    module MultiparameterHandler
      extend ActiveSupport::Concern

      # Stricter handling of date and time values from multiparameter 
      # assignment from the date/time select view helpers

      included do
        alias_method_chain :instantiate_time_object, :timeliness
        alias_method_chain :execute_callstack_for_multiparameter_attributes, :timeliness
      end

      private

      def invalid_multiparameter_date_or_time_as_string(values)
        value =  [values[0], *values[1..2].map {|s| s.to_s.rjust(2,"0")} ].join("-")
        value += ' ' + values[3..5].map {|s| s.to_s.rjust(2, "0") }.join(":") unless values[3..5].empty?
        value
      end

      def instantiate_time_object_with_timeliness(name, values)
        if Date.valid_civil?(*values[0..2])
          instantiate_time_object_without_timeliness(name, values)
        else
          invalid_multiparameter_date_or_time_as_string(values)
        end
      end

      def instantiate_date_object(name, values)
        values = values.map { |v| v.nil? ? 1 : v }
        Date.new(*values)
      rescue ArgumentError => ex
        invalid_multiparameter_date_or_time_as_string(values)
      end

      def execute_callstack_for_multiparameter_attributes_with_timeliness(callstack)
        errors = []
        callstack.each do |name, values_with_empty_parameters|
          begin
            klass = (self.class.reflect_on_aggregation(name.to_sym) || column_for_attribute(name)).klass
            values = values_with_empty_parameters.reject { |v| v.nil? }

            if values.empty?
              send(name + "=", nil)
            else

              value = if Time == klass
                instantiate_time_object(name, values)
              elsif Date == klass
                instantiate_date_object(name, values_with_empty_parameters)
              else
                klass.new(*values)
              end

              send(name + "=", value)
            end
          rescue => ex
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
