require 'spec_helper'

describe ValidatesTimeliness, 'HelperMethods' do
  it 'should define class validation methods' do
    Person.should respond_to(:validates_date)
    Person.should respond_to(:validates_time)
    Person.should respond_to(:validates_datetime)
  end

  it 'should define instance validation methods' do
    Person.new.should respond_to(:validates_date)
    Person.new.should respond_to(:validates_time)
    Person.new.should respond_to(:validates_datetime)
  end

  it 'should validate instance when validation method called' do
    r = Person.new
    r.validates_date :birth_date
    r.errors[:birth_date].should_not be_empty
  end
end
