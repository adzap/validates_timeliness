require 'spec_helper'

describe ValidatesTimeliness::AttributeMethods do
  before do
    Employee.validates_datetime :birth_datetime
    Employee.define_attribute_methods
  end

  it 'should define attribute write method for validated attributes' do
    Employee.instance_methods(false).should include("birth_datetime=")
  end

  it 'should define attribute before_type_cast method for validated attributes' do
    Employee.instance_methods(false).should include("birth_datetime_before_type_cast")
  end

  it 'should store original raw value on attribute write' do
    r = Employee.new
    r.birth_datetime = '2010-01-01'
    r.birth_datetime_before_type_cast.should == '2010-01-01'
  end
end
