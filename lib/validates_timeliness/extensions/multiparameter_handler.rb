ActiveRecord::AttributeAssignment::MultiparameterAttribute.class_eval do
  private

  # Yield if date values are valid
  def validate_multiparameter_date_values(set_values)
    if set_values[0..2].all?{ |v| v.present? } && Date.valid_civil?(*set_values[0..2])
      yield
    else
      invalid_multiparameter_date_or_time_as_string(set_values)
    end
  end

  def invalid_multiparameter_date_or_time_as_string(values)
    value =  [values[0], *values[1..2].map {|s| s.to_s.rjust(2,"0")} ].join("-")
    value += ' ' + values[3..5].map {|s| s.to_s.rjust(2, "0") }.join(":") unless values[3..5].empty?
    value
  end

  def instantiate_time_object(set_values)
    raise if set_values.any?(&:nil?)

    validate_multiparameter_date_values(set_values) {
      set_values = set_values.map {|v| v.is_a?(String) ? v.strip : v }

      if object.class.send(:create_time_zone_conversion_attribute?, name, cast_type_or_column)
        Time.zone.local(*set_values)
      else
        Time.send(object.class.default_timezone, *set_values)
      end
    }
  rescue
    invalid_multiparameter_date_or_time_as_string(set_values)
  end

  def read_time
    # If column is a :time (and not :date or :timestamp) there is no need to validate if
    # there are year/month/day fields
    if cast_type_or_column.type == :time
      # if the column is a time set the values to their defaults as January 1, 1970, but only if they're nil
      { 1 => 1970, 2 => 1, 3 => 1 }.each do |key,value|
        values[key] ||= value
      end
    end

    max_position = extract_max_param(6)
    set_values   = values.values_at(*(1..max_position))

    instantiate_time_object(set_values)
  end

  def read_date
    set_values = values.values_at(1,2,3).map {|v| v.is_a?(String) ? v.strip : v }
    
    if set_values.any? { |v| v.is_a?(String) }
      Timeliness.parse(set_values.join('-'), :date).try(:to_date) or raise TypeError
    else
      Date.new(*set_values)
    end
  rescue TypeError, ArgumentError, NoMethodError => ex # if Date.new raises an exception on an invalid date
    # Date.new with nil values throws NoMethodError
    raise ex if ex.is_a?(NoMethodError) && ex.message !~ /undefined method `div' for/
    invalid_multiparameter_date_or_time_as_string(set_values)
  end

  # Cast type is v4.2 and column before
  def cast_type_or_column
    @cast_type || @column
  end

  def timezone_conversion_attribute?
    object.class.send(:create_time_zone_conversion_attribute?, name, column)
  end

end
