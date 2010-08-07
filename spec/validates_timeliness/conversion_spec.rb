require 'spec_helper'

describe ValidatesTimeliness::Conversion do
  include ValidatesTimeliness::Conversion

  before do
    Timecop.freeze(Time.mktime(2010, 1, 1, 0, 0, 0))
  end

  describe "#type_cast_value" do
    describe "for date type" do
      it "should return same value for date value" do
        type_cast_value(Date.new(2010, 1, 1), :date).should == Date.new(2010, 1, 1)
      end

      it "should return date part of time value" do
        type_cast_value(Time.mktime(2010, 1, 1, 0, 0, 0), :date).should == Date.new(2010, 1, 1)
      end

      it "should return date part of datetime value" do
        type_cast_value(DateTime.new(2010, 1, 1, 0, 0, 0), :date).should == Date.new(2010, 1, 1)
      end
    end

    describe "for time type" do
      it "should return same value for time value matching dummy date part" do
        type_cast_value(Time.mktime(2000, 1, 1, 0, 0, 0), :time).should == Time.mktime(2000, 1, 1, 0, 0, 0)
      end

      it "should return dummy time value with same time part for time value with different date" do
        type_cast_value(Time.mktime(2010, 1, 1, 0, 0, 0), :time).should == Time.mktime(2000, 1, 1, 0, 0, 0)
      end

      it "should return dummy time only for date value" do
        type_cast_value(Date.new(2010, 1, 1), :time).should == Time.mktime(2000, 1, 1, 0, 0, 0)
      end

      it "should return dummy date with shifted local time for UTC datetime value" do
        type_cast_value(DateTime.new(2010, 1, 1, 12, 34, 56), :time).should == Time.mktime(2000, 1, 1, 23, 34, 56)
      end

      it "should return dummy date with time part for local datetime value" do
        type_cast_value(DateTime.civil_from_format(:local, 2010, 1, 1, 12, 34, 56), :time).should == Time.mktime(2000, 1, 1, 12, 34, 56)
      end
    end

    describe "for datetime type" do
      it "should return time in local offset for date value" do
        type_cast_value(Date.new(2010, 1, 1), :datetime).should == Time.local_time(2010, 1, 1, 0, 0, 0)
      end

      it "should return same value for same time value in local offset" do
        type_cast_value(Time.local_time(2010, 1, 1, 12, 34, 56), :datetime).should == Time.local_time(2010, 1, 1, 12, 34, 56)
      end

      it "should return shifted local time value for UTC time value" do
        type_cast_value(Time.utc(2010, 1, 1, 12, 34, 56), :datetime).should == Time.local_time(2010, 1, 1, 23, 34, 56)
      end

      it "should return shifted local time value for UTC datetime value" do
        type_cast_value(DateTime.new(2010, 1, 1, 12, 34, 56), :datetime).should == Time.local_time(2010, 1, 1, 23, 34, 56)
      end

      it "should return time value with same component values for local datetime value" do
        type_cast_value(DateTime.civil_from_format(:local, 2010, 1, 1, 12, 34, 56), :datetime).should == Time.local_time(2010, 1, 1, 12, 34, 56)
      end
    end
  end

  describe "#dummy_time" do
    it 'should return dummy date with shifted local time part for UTC time value' do
      dummy_time(Time.utc(2010, 11, 22, 12, 34, 56)).should == Time.local_time(2000, 1, 1, 23, 34, 56)
    end

    it 'should return dummy date with same time part part for local time value with non-dummy date' do
      dummy_time(Time.local_time(2010, 11, 22, 12, 34, 56)).should == Time.local_time(2000, 1, 1, 12, 34, 56)
    end

    it 'should return same value for local time with dummy date' do
      dummy_time(Time.local_time(2000, 1, 1, 12, 34, 56)).should == Time.local_time(2000, 1, 1, 12, 34, 56)
    end

    it 'should return exact dummy time value for date value' do
      dummy_time(Date.new(2010, 11, 22)).should == Time.mktime(2000, 1, 1, 0, 0, 0)
    end

    describe "with custom dummy date" do
      before(:all) do
        @@original_dummy_date = ValidatesTimeliness.dummy_date_for_time_type
        ValidatesTimeliness.dummy_date_for_time_type = [2010, 1, 1] 
      end

      it 'should return dummy time with custom dummy date' do
        dummy_time(Time.local_time(1999, 11, 22, 12, 34, 56)).should == Time.local_time(2010, 1, 1, 12, 34, 56)
      end

      after(:all) do
        ValidatesTimeliness.dummy_date_for_time_type = @@original_dummy_date
      end
    end
  end

  describe "#evaluate_option_value" do
    let(:person) { Person.new }

    it 'should return Date object as is' do
      value = Date.new(2010,1,1)
      evaluate_option_value(value, person).should == value
    end

    it 'should return Time object as is' do
      value = Time.mktime(2010,1,1)
      evaluate_option_value(value, person).should == value
    end

    it 'should return DateTime object as is' do
      value = DateTime.new(2010,1,1,0,0,0)
      evaluate_option_value(value, person).should == value
    end

    it 'should return local Time value from string time value' do
      value = '2010-01-01 12:00:00'
      evaluate_option_value(value, person).should == Time.mktime(2010,1,1,12,0,0)
    end

    it 'should return Time value returned from proc with 0 arity' do
      value = Time.mktime(2010,1,1)
      evaluate_option_value(lambda { value }, person).should == value
    end

    it 'should return Time value returned by record attribute call in proc arity of 1' do
      value = Time.mktime(2010,1,1)
      person.birth_time = value
      evaluate_option_value(lambda {|r| r.birth_time }, person).should == value
    end

    it 'should return Time value from proc which returns string time' do
      value = '2010-01-01 12:00:00'
      evaluate_option_value(lambda { value }, person).should == Time.mktime(2010,1,1,12,0,0)
    end

    it 'should return Time value for attribute method symbol which returns Time' do
      value = Time.mktime(2010,1,1)
      person.birth_time = value
      evaluate_option_value(:birth_time, person).should == value
    end

    it 'should return Time value for attribute method symbol which returns string time value' do
      value = '2010-01-01 12:00:00'
      person.birth_time = value
      evaluate_option_value(:birth_time, person).should == Time.mktime(2010,1,1,12,0,0)
    end

    context "restriction shorthand" do
      before do
        Timecop.freeze(Time.mktime(2010, 1, 1, 0, 0, 0))
      end

      it 'should evaluate :now as current time' do
        evaluate_option_value(:now, person).should == Time.now
      end

      it 'should evaluate :today as current time' do
        evaluate_option_value(:today, person).should == Date.today
      end

      it 'should not use shorthand if symbol if is record method' do
        time = 1.day.from_now
        person.stub!(:now).and_return(time)
        evaluate_option_value(:now, person).should == time
      end
    end
  end
end
