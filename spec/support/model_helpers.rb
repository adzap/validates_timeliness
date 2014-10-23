module ModelHelpers 

  # Some test helpers from Rails source 
  def invalid!(attr_name, values, error = nil)
    with_each_person_value(attr_name, values) do |record, value|
      expect(record).to be_invalid
      expect(record.errors[attr_name].size).to be >= 1
      expect(record.errors[attr_name].first).to eq(error) if error
    end
  end

  def valid!(attr_name, values)
    with_each_person_value(attr_name, values) do |record, value|
      expect(record).to be_valid
    end
  end

  def with_each_person_value(attr_name, values)
    record = Person.new
    values = [values] unless values.is_a?(Array)
    values.each do |value|
      record.send("#{attr_name}=", value)
      yield record, value
    end
  end

end
