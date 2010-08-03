require 'spec_helper'

describe ValidatesTimeliness::Extensions::MultiparameterHandler do
  let(:employee) { Employee.new }

  it 'should return string value for invalid dates' do
    instantiate_time_object('birth_date', [2000, 2, 31]).should == '2000-02-31'
  end

  it 'should return string value for invalid datetimes' do
    instantiate_time_object('birth_datetime', [2000, 2, 31, 12, 0, 0]).should == '2000-02-31 12:00:00'
  end

  # This is giving an error in AR for undefined @@default_timezone.
  # it 'should return Time value for valid datetimes' do
  #   instantiate_time_object('birth_datetime', [2000, 2, 28, 12, 0, 0]).should be_find_of(Time)
  # end

  def instantiate_time_object(name, values)
    employee.send(:instantiate_time_object, name, values)
  end
end
