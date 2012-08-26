require 'spec_helper'

describe ValidatesTimeliness, 'HelperMethods' do
  let(:record) { Person.new }
  
  it 'should define class validation methods' do
    Person.should respond_to(:validates_date)
    Person.should respond_to(:validates_time)
    Person.should respond_to(:validates_datetime)
  end

  it 'should define instance validation methods' do
    record.should respond_to(:validates_date)
    record.should respond_to(:validates_time)
    record.should respond_to(:validates_datetime)
  end

  it 'should validate instance using class validation defined' do
    Person.validates_date :birth_date
    record.valid?

    record.errors[:birth_date].should_not be_empty
  end

  it 'should validate instance using instance valiation method' do
    record.validates_date :birth_date

    record.errors[:birth_date].should_not be_empty
  end
end
