require 'spec_helper'

describe ValidatesTimeliness::AttributeMethods do
  it 'should define _timeliness_raw_value_for instance method' do
    Person.instance_methods.should include('_timeliness_raw_value_for')
  end
  
  context "attribute write method" do
    class EmployeeWithCache < ActiveRecord::Base
      set_table_name 'employees'
      validates_datetime :birth_datetime
    end

    it 'should cache attribute raw value' do
      r = EmployeeWithCache.new
      r.birth_datetime = date_string = '2010-01-01'
      r._timeliness_raw_value_for(:birth_datetime).should == date_string
    end

    context "with plugin parser" do
      class EmployeeWithParser < ActiveRecord::Base
        set_table_name 'employees'
        validates_datetime :birth_date
      end

      before :all do
        ValidatesTimeliness.use_plugin_parser = true
      end

      it 'should parse a string value' do
        ValidatesTimeliness::Parser.should_receive(:parse) 
        r = EmployeeWithParser.new
        r.birth_date = '2010-01-01'
      end

      it 'should be strict on day values' do
        r = EmployeeWithParser.new
        r.birth_date = '2010-02-31'
        r.birth_date.should be_nil
      end

      after :all do
        ValidatesTimeliness.use_plugin_parser = false
      end
    end
  end

  context "before_type_cast method" do
    it 'should be defined on class if ORM supports it' do
      Employee.instance_methods(false).should include("birth_datetime_before_type_cast")
    end

    it 'should not be defined if ORM does not support it' do
      Person.instance_methods(false).should_not include("birth_datetime_before_type_cast")
    end

    it 'should return original value' do
      r = Employee.new
      r.birth_datetime = date_string = '2010-01-01'
      r.birth_datetime_before_type_cast.should == date_string
    end
  end
end
