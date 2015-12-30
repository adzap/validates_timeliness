RSpec.describe ValidatesTimeliness, 'HelperMethods' do
  let(:record) { Person.new }
  
  it 'should define class validation methods' do
    expect(Person).to respond_to(:validates_date)
    expect(Person).to respond_to(:validates_time)
    expect(Person).to respond_to(:validates_datetime)
  end

  it 'should define instance validation methods' do
    expect(record).to respond_to(:validates_date)
    expect(record).to respond_to(:validates_time)
    expect(record).to respond_to(:validates_datetime)
  end

  it 'should validate instance using class validation defined' do
    Person.validates_date :birth_date
    record.valid?

    expect(record.errors[:birth_date]).not_to be_empty
  end

  it 'should validate instance using instance valiation method' do
    record.validates_date :birth_date

    expect(record.errors[:birth_date]).not_to be_empty
  end
end
