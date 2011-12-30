require 'spec_helper'

describe ValidatesTimeliness::Extensions::MultiparameterHandler do
  let(:employee) { Employee.new }

  context "time column" do
    context "given an array callstack as in Rails 3.0 and before" do
      it 'should return string value for invalid date portion' do
        multiparameter_attribute(:birth_datetime, [2000, 2, 31, 12, 0, 0])
        employee.birth_datetime_before_type_cast.should == '2000-02-31 12:00:00'
      end

      it 'should return Time value for valid datetimes' do
        multiparameter_attribute(:birth_datetime, [2000, 2, 28, 12, 0, 0])
        employee.birth_datetime_before_type_cast.should be_kind_of(Time)
      end
    end

    context "given a hash callstack as in Rails 3.1+" do
      it 'should return string value for invalid date portion' do
        multiparameter_attribute(:birth_datetime, { 1 => 2000, 2 => 2, 3 => 31, 4 => 12, 5 => 0, 6 => 0 })
        employee.birth_datetime_before_type_cast.should == '2000-02-31 12:00:00'
      end

      it 'should return Time value for valid datetimes' do
        multiparameter_attribute(:birth_datetime, { 1 => 2000, 2 => 2, 3 => 28, 4 => 12, 5 => 0, 6 => 0 })
        employee.birth_datetime_before_type_cast.should be_kind_of(Time)
      end
    end
  end

  context "date column" do
    context "given an array callstack as in Rails 3.0 and before" do
      it 'should return string value for partial date' do
        multiparameter_attribute(:birth_date, [nil, 2, 28])
        employee.birth_date_before_type_cast.should == '-02-28'
        employee.birth_date.should be_nil
      end

      it 'should return string value for invalid date' do
        multiparameter_attribute(:birth_date, [2000, 2, 31])
        employee.birth_date_before_type_cast.should == '2000-02-31'
        employee.birth_date.should be_nil
      end

      it 'should return Date value for valid date' do
        multiparameter_attribute(:birth_date, [2000, 2, 28])
        employee.birth_date_before_type_cast.should be_kind_of(Date)
        employee.birth_date.should == Date.new(2000, 2, 28)
      end
    end

    context "given a hash callstack as in Rails 3.1+" do
      it 'should return string value for partial date' do
        multiparameter_attribute(:birth_date, { 1 => nil, 2 => 2, 3 => 28 })
        employee.birth_date_before_type_cast.should == '-02-28'
        employee.birth_date.should be_nil
      end

      it 'should return string value for invalid date' do
        multiparameter_attribute(:birth_date, { 1 => 2000, 2 => 2, 3 => 31 })
        employee.birth_date_before_type_cast.should == '2000-02-31'
        employee.birth_date.should be_nil
      end

      it 'should return Date value for valid date' do
        multiparameter_attribute(:birth_date, { 1 => 2000, 2 => 2, 3 => 28 })
        employee.birth_date_before_type_cast.should be_kind_of(Date)
        employee.birth_date.should == Date.new(2000, 2, 28)
      end
    end
  end

  def multiparameter_attribute(name, values)
    employee.send(:execute_callstack_for_multiparameter_attributes, name.to_s => values)
  end
end
