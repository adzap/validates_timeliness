module ValidatesTimeliness
  module Extensions
    class AcceptsMultiparameterTime < Module

      def initialize(defaults: {})

        define_method(:cast) do |value|
          if value.is_a?(Hash)
            value_from_multiparameter_assignment(value)
          else
            super(value)
          end
        end

        define_method(:assert_valid_value) do |value|
          if value.is_a?(Hash)
            value_from_multiparameter_assignment(value)
          else
            super(value)
          end
        end

        define_method(:value_from_multiparameter_assignment) do |values_hash|
          defaults.each do |k, v|
            values_hash[k] ||= v
          end
          return unless values_hash.values_at(1,2,3).all?{ |v| v.present? } &&
                          Date.valid_civil?(*values_hash.values_at(1,2,3))

          values = values_hash.sort.map(&:last)
          ::Time.send(default_timezone, *values)
        end
        private :value_from_multiparameter_assignment

      end

    end
  end
end

ActiveModel::Type::Date.class_eval do
  include ValidatesTimeliness::Extensions::AcceptsMultiparameterTime.new
end

ActiveModel::Type::Time.class_eval do
  include ValidatesTimeliness::Extensions::AcceptsMultiparameterTime.new(
    defaults: { 1 => 1970, 2 => 1, 3 => 1, 4 => 0, 5 => 0 }
  )
end

ActiveModel::Type::DateTime.class_eval do
  include ValidatesTimeliness::Extensions::AcceptsMultiparameterTime.new(
    defaults: { 4 => 0, 5 => 0 }
  )
end