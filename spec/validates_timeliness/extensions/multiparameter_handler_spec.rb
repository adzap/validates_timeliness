require 'spec_helper'

describe ValidatesTimeliness::Extensions::MultiparameterHandler do
  let(:employee) { Employee.new }

  context "time column" do
    it 'should return string value for invalid date portion' do
      multiparameter_attribute(:birth_datetime, [2000, 2, 31, 12, 0, 0])
      employee.birth_datetime_before_type_cast.should == '2000-02-31 12:00:00'
    end
     
    it 'should return Time value for valid datetimes' do
      multiparameter_attribute(:birth_datetime, [2000, 2, 28, 12, 0, 0])
      employee.birth_datetime_before_type_cast.should be_kind_of(Time)
    end
  end

  context "date column" do
    it 'should return string value for invalid date' do
      multiparameter_attribute(:birth_date, [2000, 2, 31])
      employee.birth_date_before_type_cast.should == '2000-02-31'
    end

    it 'should return Date value for valid date' do
      multiparameter_attribute(:birth_date, [2000, 2, 28])
      employee.birth_date_before_type_cast.should be_kind_of(Date)
    end
  end

  def multiparameter_attribute(name, values)
    employee.send(:execute_callstack_for_multiparameter_attributes, name.to_s => values)
  end
end
