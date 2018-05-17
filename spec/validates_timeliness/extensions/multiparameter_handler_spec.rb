RSpec.describe 'ValidatesTimeliness::Extensions::MultiparameterHandler' do

  context "time column" do
    it 'should be nil invalid date portion' do
      employee = record_with_multiparameter_attribute(:birth_datetime, [2000, 2, 31, 12, 0, 0])
      expect(employee.birth_datetime).to be_nil
    end
     
    it 'should assign a Time value for valid datetimes' do
      employee = record_with_multiparameter_attribute(:birth_datetime, [2000, 2, 28, 12, 0, 0])
      expect(employee.birth_datetime).to eq Time.zone.local(2000, 2, 28, 12, 0, 0)
    end

    it 'should be nil for incomplete date portion' do
      employee = record_with_multiparameter_attribute(:birth_datetime, [2000, nil, nil])
      expect(employee.birth_datetime).to be_nil
    end
  end

  context "date column" do
    it 'should assign nil for invalid date' do
      employee = record_with_multiparameter_attribute(:birth_date, [2000, 2, 31])
      expect(employee.birth_date).to be_nil
    end

    it 'should assign a Date value for valid date' do
      employee = record_with_multiparameter_attribute(:birth_date, [2000, 2, 28])
      expect(employee.birth_date).to eq Date.new(2000, 2, 28)
    end

    it 'should assign hash values for incomplete date' do
      employee = record_with_multiparameter_attribute(:birth_date, [2000, nil, nil])
      expect(employee.birth_date).to be_nil
    end
  end

  def record_with_multiparameter_attribute(name, values)
    hash = {}
    values.each_with_index {|value, index| hash["#{name}(#{index+1}i)"] = value.to_s }
    Employee.new(hash)
  end

end
