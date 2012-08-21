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

    it "should validate a valid value string" do
      r = Employee.new
      r.birth_date = '2012-01-01'

      r.valid?
      r.errors[:birth_date].should be_empty
    end

    it "should validate a invalid value string" do
      r = Employee.new
      r.birth_date = 'not a date'

      r.valid?
      r.errors[:birth_date].should_not be_empty
    end

    it "should validate a nil value" do
      r = Employee.new
      r.birth_date = nil

      r.valid?
      r.errors[:birth_date].should be_empty
    end
  end

  it 'should determine type for attribute' do
    Employee.timeliness_attribute_type(:birth_date).should eq :date
  end

  context 'attribute timezone awareness' do
    let(:klass) {
      Class.new(ActiveRecord::Base) do
        self.table_name = 'employees'
        attr_accessor :some_date
        attr_accessor :some_time
        attr_accessor :some_datetime
        validates_date :some_date
        validates_time :some_time
        validates_datetime :some_datetime
      end
    }

    context 'for column attribute' do
      it 'should be detected from column type' do
        klass.timeliness_attribute_timezone_aware?(:birth_date).should be_false
        klass.timeliness_attribute_timezone_aware?(:birth_time).should be_false
        klass.timeliness_attribute_timezone_aware?(:birth_datetime).should be_true
      end
    end

    context 'for non-column attribute' do
      it 'should be detected from the validation type' do
        klass.timeliness_attribute_timezone_aware?(:some_date).should be_false
        klass.timeliness_attribute_timezone_aware?(:some_time).should be_false
        klass.timeliness_attribute_timezone_aware?(:some_datetime).should be_true
      end
    end
  end
  
  context "attribute write method" do
    class EmployeeWithCache < ActiveRecord::Base
      self.table_name = 'employees'
      validates_date :birth_date, :allow_blank => true
      validates_time :birth_time, :allow_blank => true
      validates_datetime :birth_datetime, :allow_blank => true
    end

    context 'value cache' do
      context 'for datetime column' do
        it 'should store raw value' do
          r = EmployeeWithCache.new
          r.birth_datetime = datetime_string = '2010-01-01 12:30'

          r._timeliness_raw_value_for('birth_datetime').should eq datetime_string
        end
      end

      context 'for date column' do
        it 'should store raw value' do
          r = EmployeeWithCache.new
          r.birth_date = date_string = '2010-01-01'

          r._timeliness_raw_value_for('birth_date').should eq date_string
        end
      end

      context 'for time column' do
        it 'should store raw value' do
          r = EmployeeWithCache.new
          r.birth_time = time_string = '12:12'

          r._timeliness_raw_value_for('birth_time').should eq time_string
        end
      end
    end

    context "with plugin parser" do
      with_config(:use_plugin_parser, true)

      class EmployeeWithParser < ActiveRecord::Base
        self.table_name = 'employees'
        validates_date :birth_date, :allow_blank => true
        validates_time :birth_time, :allow_blank => true
        validates_datetime :birth_datetime, :allow_blank => true
      end

      context "for a date column" do
        it 'should parse a string value' do
          Timeliness::Parser.should_receive(:parse)

          r = EmployeeWithParser.new
          r.birth_date = '2010-01-01'
        end

        it 'should parse a invalid string value as nil' do
          Timeliness::Parser.should_receive(:parse)
          r = EmployeeWithParser.new
          r.birth_date = 'not valid'
        end

        it 'should store a Date value after parsing string' do
          r = EmployeeWithParser.new
          r.birth_date = '2010-01-01'

          r.birth_date.should be_kind_of(Date)
          r.birth_date.should eq Date.new(2010, 1, 1)
        end
      end

      context "for a time column" do
        it 'should parse a string value' do
          Timeliness::Parser.should_receive(:parse)

          r = EmployeeWithParser.new
          r.birth_time = '12:30'
        end

        it 'should parse a invalid string value as nil' do
          Timeliness::Parser.should_receive(:parse)

          r = EmployeeWithParser.new
          r.birth_time = 'not valid'
        end

        it 'should store a Time value after parsing string' do
          r = EmployeeWithParser.new
          r.birth_time = '12:30'

          r.birth_time.should be_kind_of(Time)
          r.birth_time.should eq Time.utc(2000, 1, 1, 12, 30)
        end
      end

      context "for a datetime column" do
        with_config(:default_timezone, 'Australia/Melbourne')

        it 'should parse a string value' do
          Timeliness::Parser.should_receive(:parse)

          r = EmployeeWithParser.new
          r.birth_datetime = '2010-01-01 12:00'
        end

        it 'should parse a invalid string value as nil' do
          Timeliness::Parser.should_receive(:parse)

          r = EmployeeWithParser.new
          r.birth_datetime = 'not valid'
        end

        it 'should parse string into Time value' do
          r = EmployeeWithParser.new
          r.birth_datetime = '2010-01-01 12:00'

          r.birth_datetime.should be_kind_of(Time)
        end

        it 'should parse string as current timezone' do
          r = EmployeeWithParser.new
          r.birth_datetime = '2010-06-01 12:00'

          r.birth_datetime.utc_offset.should eq Time.zone.utc_offset
        end
      end
    end
  end

  context "reload" do
    it 'should clear cache value' do
      r = Employee.create!
      r.birth_date = '2010-01-01'
      
      r.reload

      r._timeliness_raw_value_for('birth_date').should be_nil
    end
  end

  context "before_type_cast method" do
    it 'should be defined on class if ORM supports it' do
      Employee.new.should respond_to(:birth_datetime_before_type_cast)
    end

    it 'should return original value' do
      r = Employee.new
      r.birth_datetime = date_string = '2010-01-01'

      r.birth_datetime_before_type_cast.should eq date_string
    end

    it 'should return attribute if no attribute assignment has been made' do
      datetime = Time.zone.local(2010,01,01)
      Employee.create(:birth_datetime => datetime)

      r = Employee.last
      r.birth_datetime_before_type_cast.should match(/2010-01-01 00:00:00/)
    end

    context "with plugin parser" do
      with_config(:use_plugin_parser, true)

      it 'should return original value' do
        r = Employee.new
        r.birth_datetime = date_string = '2010-01-31'

        r.birth_datetime_before_type_cast.should eq date_string
      end
    end

  end

  context "define_attribute_methods" do
    it "returns a falsy value if the attribute methods have already been generated" do
      Employee.define_attribute_methods.should be_false
    end
  end
end
