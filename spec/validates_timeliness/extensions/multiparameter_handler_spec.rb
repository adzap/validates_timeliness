RSpec.describe 'ValidatesTimeliness::Extensions::MultiparameterHandler' do

  context "time column" do
    it 'should assign a string value for invalid date portion' do
      employee = record_with_multiparameter_attribute(:birth_datetime, [2000, 2, 31, 12, 0, 0])
      expect(employee.birth_datetime_before_type_cast).to eq '2000-02-31 12:00:00'
    end
     
    it 'should assign a Time value for valid datetimes' do
      employee = record_with_multiparameter_attribute(:birth_datetime, [2000, 2, 28, 12, 0, 0])
      expect(employee.birth_datetime_before_type_cast).to eq Time.zone.local(2000, 2, 28, 12, 0, 0)
    end

    it 'should assign a string value for incomplete time' do
      employee = record_with_multiparameter_attribute(:birth_datetime, [2000, nil, nil])
      expect(employee.birth_datetime_before_type_cast).to eq '2000-00-00'
    end
  end

  context "date column" do
    it 'should assign a string value for invalid date' do
      employee = record_with_multiparameter_attribute(:birth_date, [2000, 2, 31])
      expect(employee.birth_date_before_type_cast).to eq '2000-02-31'
    end

    it 'should assign a Date value for valid date' do
      employee = record_with_multiparameter_attribute(:birth_date, [2000, 2, 28])
      expect(employee.birth_date_before_type_cast).to eq Date.new(2000, 2, 28)
    end

    it 'should assign a string value for incomplete date' do
      employee = record_with_multiparameter_attribute(:birth_date, [2000, nil, nil])
      expect(employee.birth_date_before_type_cast).to eq '2000-00-00'
    end
  end

  def record_with_multiparameter_attribute(name, values)
    hash = {}
    values.each_with_index {|value, index| hash["#{name}(#{index+1}i)"] = value.to_s }
    Employee.new(hash)
  end

end
