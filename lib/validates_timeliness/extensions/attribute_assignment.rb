module ValidatesTimeliness
  module Extensions
    module AttributeAssignment
      extend ActiveSupport::Concern

      # Stricter handling of date and time values from multiparameter
      # assignment from the date/time select view helpers

      included do
        alias_method :execute_callstack_for_multiparameter_attributes, :execute_callstack_for_multiparameter_attributes_with_timeliness
      end

      private

      def execute_callstack_for_multiparameter_attributes_with_timeliness(callstack)
        errors = []
        callstack.each do |name, values_with_empty_parameters|
          begin
            send("#{name}=", self.class::MultiparameterAttribute.new(self, name, values_with_empty_parameters).read_value)
          rescue => ex
            values = values_with_empty_parameters.is_a?(Hash) ? values_with_empty_parameters.values : values_with_empty_parameters
            errors << ActiveRecord::AttributeAssignmentError.new("error on assignment #{values.inspect} to #{name} (#{ex.message})", ex, name)
          end
        end
        unless errors.empty?
          error_descriptions = errors.map { |ex| ex.message }.join(",")
          raise ActiveRecord::MultiparameterAssignmentErrors.new(errors), "#{errors.size} error(s) on assignment of multiparameter attributes [#{error_descriptions}]"
        end
      end

    end
  end
end
