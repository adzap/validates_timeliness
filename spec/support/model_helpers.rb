module ModelHelpers 

  # Some test helpers from Rails source 
  def invalid!(attr_name, values, error = nil, model_class = Person)
    with_each_model_value(attr_name, values, model_class) do |record, value|
      expect(record).to_not be_valid
      expect(record.errors[attr_name].size).to be >= 1

      return unless error

      if error.is_a?(Regexp)
        expect(record.errors[attr_name].first).to match(error)
      else
        expect(record.errors[attr_name].first).to eq(error)
      end
    end
  end

  def valid!(attr_name, values, model_class = Person)
    with_each_model_value(attr_name, values, model_class) do |record, value|
      expect(record).to be_valid
    end
  end

  def with_each_model_value(attr_name, values, model_class)
    record = model_class.new
    Array.wrap(values).each do |value|
      record.send("#{attr_name}=", value)
      yield record, value
    end
  end

end
