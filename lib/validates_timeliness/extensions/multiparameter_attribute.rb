module ValidatesTimeliness
  module Extensions
    module MultiparameterAttribute
      extend ActiveSupport::Concern

      # Stricter handling of date and time values from multiparameter
      # assignment from the date/time select view helpers

      included do
        alias_method_chain :instantiate_time_object, :timeliness
        alias_method :read_value, :read_value_with_timeliness
      end


#      private

      def invalid_multiparameter_date_or_time_as_string(set_values)
        value =  [set_values[0], *set_values[1..2].map {|s| s.to_s.rjust(2,"0")} ].join("-")
        value += ' ' + set_values[3..5].map {|s| s.to_s.rjust(2, "0") }.join(":") unless set_values[3..5].empty?
        value
      end

      def instantiate_time_object_with_timeliness(set_values)
        validate_multiparameter_date_values(set_values) {
          instantiate_time_object_without_timeliness(set_values)
        }
      end

      def instantiate_date_object(set_values)
        validate_multiparameter_date_values(set_values) {
          Date.new(*set_values)
        }
      end

      # Yield if date values are valid
      def validate_multiparameter_date_values(set_values)
        if set_values[0..2].all?{ |v| v.present? } && Date.valid_civil?(*set_values[0..2])
          yield
        else
          invalid_multiparameter_date_or_time_as_string(set_values)
        end
      end

      def read_value_with_timeliness
        @column = object.class.reflect_on_aggregation(name.to_sym) || object.column_for_attribute(name)
        klass   = column.klass

        set_values = values.is_a?(Hash) ? values.to_a.sort_by(&:first).map(&:last) : values
        if set_values.empty? || set_values.all?{ |v| v.nil? }
          nil
        elsif klass == Time
          instantiate_time_object(set_values)
        elsif klass == Date
          instantiate_date_object(set_values)
        else
          if respond_to?(:read_other_parameter_value)
            read_date_parameter_value(name, values)
          else
            klass.new(*set_values)
          end
        end
      end

    end
  end
end
