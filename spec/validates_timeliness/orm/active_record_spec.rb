require 'spec_helper'

describe ValidatesTimeliness, 'ActiveRecord' do

  context "validation methods" do
    it 'should be defined for the class' do
      ActiveRecord::Base.should respond_to(:validates_date)
      ActiveRecord::Base.should respond_to(:validates_time)
      ActiveRecord::Base.should respond_to(:validates_datetime)
    end

    it 'should defines for the instance' do
      Employee.new.should respond_to(:validates_date)
      Employee.new.should respond_to(:validates_time)
      Employee.new.should respond_to(:validates_datetime)
    end
  end

  it 'should determine type for attribute' do
    Employee.timeliness_attribute_type(:birth_date).should == :date
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
      with_config(:use_plugin_parser, true)

      class EmployeeWithParser < ActiveRecord::Base
        set_table_name 'employees'
        validates_date :birth_date
        validates_datetime :birth_datetime
      end

      it 'should parse a string value' do
        Timeliness::Parser.should_receive(:parse)
        r = EmployeeWithParser.new
        r.birth_date = '2010-01-01'
      end

      context "for a date column" do
        it 'should store a date value after parsing string' do
          r = EmployeeWithParser.new
          r.birth_date = '2010-01-01'

          r.birth_date.should be_kind_of(Date)
          r.birth_date.should == Date.new(2010, 1, 1)
        end
      end

      context "for a datetime column" do
        with_config(:default_timezone, 'Australia/Melbourne')

        it 'should parse string into Time value' do
          r = EmployeeWithParser.new
          r.birth_datetime = '2010-01-01 12:00'

          r.birth_datetime.should be_kind_of(Time)
        end

        it 'should parse string as current timezone' do
          r = EmployeeWithParser.new
          r.birth_datetime = '2010-06-01 12:00'

          r.birth_datetime.utc_offset.should == Time.zone.utc_offset
        end
      end
    end
  end

  context "cached value" do
    it 'should be cleared on reload' do
      r = Employee.create!
      r.birth_date = '2010-01-01'
      r.reload
      r._timeliness_raw_value_for(:birth_date).should be_nil
    end
  end

  context "before_type_cast method" do
    it 'should be defined on class if ORM supports it' do
      Employee.new.should respond_to(:birth_datetime_before_type_cast)
    end

    it 'should return original value' do
      r = Employee.new
      r.birth_datetime = date_string = '2010-01-01'
      r.birth_datetime_before_type_cast.should == date_string
    end
  end
end
