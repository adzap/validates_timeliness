require 'spec_helper'

describe ValidatesTimeliness::Conversion do
  include ValidatesTimeliness::Conversion

  let(:options) { Hash.new }

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

      it 'should return nil for invalid value types' do
        type_cast_value(12, :date).should == nil
      end
    end

    describe "for time type" do
      it "should return same value for time value matching dummy date part" do
        type_cast_value(Time.utc(2000, 1, 1, 0, 0, 0), :time).should == Time.utc(2000, 1, 1, 0, 0, 0)
      end

      it "should return dummy time value with same time part for time value with different date" do
        type_cast_value(Time.utc(2010, 1, 1, 0, 0, 0), :time).should == Time.utc(2000, 1, 1, 0, 0, 0)
      end

      it "should return dummy time only for date value" do
        type_cast_value(Date.new(2010, 1, 1), :time).should == Time.utc(2000, 1, 1, 0, 0, 0)
      end

      it "should return dummy date with time part for datetime value" do
        type_cast_value(DateTime.civil_from_format(:utc, 2010, 1, 1, 12, 34, 56), :time).should == Time.utc(2000, 1, 1, 12, 34, 56)
      end

      it 'should return nil for invalid value types' do
        type_cast_value(12, :time).should == nil
      end
    end

    describe "for datetime type" do
      it "should return Date as Time value" do
        type_cast_value(Date.new(2010, 1, 1), :datetime).should == Time.local_time(2010, 1, 1, 0, 0, 0)
      end

      it "should return same Time value" do
        value = Time.utc(2010, 1, 1, 12, 34, 56)
        type_cast_value(Time.utc(2010, 1, 1, 12, 34, 56), :datetime).should == value
      end

      it "should return as Time with same component values" do
        type_cast_value(DateTime.civil_from_format(:utc, 2010, 1, 1, 12, 34, 56), :datetime).should == Time.utc(2010, 1, 1, 12, 34, 56)
      end

      it "should return same Time in correct zone if timezone aware" do
        @timezone_aware = true
        value = Time.utc(2010, 1, 1, 12, 34, 56)
        result = type_cast_value(value, :datetime)
        result.should == Time.zone.local(2010, 1, 1, 23, 34, 56)
        result.zone.should == 'EST'
      end

      it 'should return nil for invalid value types' do
        type_cast_value(12, :datetime).should == nil
      end
    end

    describe "ignore_usec option" do
      let(:options) { {:ignore_usec => true} }

      it "should ignore usec on time values when evaluated" do
        value = Time.utc(2010, 1, 1, 12, 34, 56, 10000)
        type_cast_value(value, :datetime).should == Time.utc(2010, 1, 1, 12, 34, 56)
      end

      it "should ignore usec and return time in correct zone if timezone aware" do
        @timezone_aware = true
        value = Time.utc(2010, 1, 1, 12, 34, 56, 10000)
        result = type_cast_value(value, :datetime)
        result.should == Time.zone.local(2010, 1, 1, 23, 34, 56)
        result.zone.should == 'EST'
      end
    end
  end

  describe "#dummy_time" do
    it 'should return Time with dummy date values but same time components' do
      dummy_time(Time.utc(2010, 11, 22, 12, 34, 56)).should == Time.utc(2000, 1, 1, 12, 34, 56)
    end

    it 'should return same value for Time which already has dummy date values' do
      dummy_time(Time.utc(2000, 1, 1, 12, 34, 56)).should == Time.utc(2000, 1, 1, 12, 34, 56)
    end

    it 'should return time component values shifted to current zone if timezone aware' do
      @timezone_aware = true
      dummy_time(Time.utc(2000, 1, 1, 12, 34, 56)).should == Time.zone.local(2000, 1, 1, 23, 34, 56)
    end

    it 'should return base dummy time value for Date value' do
      dummy_time(Date.new(2010, 11, 22)).should == Time.utc(2000, 1, 1, 0, 0, 0)
    end

    describe "with custom dummy date" do
      it 'should return dummy time with custom dummy date' do
        with_config(:dummy_date_for_time_type, [2010, 1, 1] ) do
          dummy_time(Time.utc(1999, 11, 22, 12, 34, 56)).should == Time.utc(2010, 1, 1, 12, 34, 56)
        end
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

    it 'should return Time value returned from proc with 0 arity' do
      value = Time.mktime(2010,1,1)
      evaluate_option_value(lambda { value }, person).should == value
    end

    it 'should return Time value returned by record attribute call in proc arity of 1' do
      value = Time.mktime(2010,1,1)
      person.birth_time = value
      evaluate_option_value(lambda {|r| r.birth_time }, person).should == value
    end

    it 'should return Time value for attribute method symbol which returns Time' do
      value = Time.mktime(2010,1,1)
      person.birth_time = value
      evaluate_option_value(:birth_time, person).should == value
    end

    it 'should return Time value is default zone from string time value' do
      value = '2010-01-01 12:00:00'
      evaluate_option_value(value, person).should == Time.utc(2010,1,1,12,0,0)
    end

    it 'should return Time value is current zone from string time value if timezone aware' do
      @timezone_aware = true
      value = '2010-01-01 12:00:00'
      evaluate_option_value(value, person).should == Time.zone.local(2010,1,1,12,0,0)
    end

    it 'should return Time value in default zone from proc which returns string time' do
      value = '2010-01-01 12:00:00'
      evaluate_option_value(lambda { value }, person).should == Time.utc(2010,1,1,12,0,0)
    end

    it 'should return Time value for attribute method symbol which returns string time value' do
      value = '2010-01-01 12:00:00'
      person.birth_time = value
      evaluate_option_value(:birth_time, person).should == Time.utc(2010,1,1,12,0,0)
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

  describe "#parse" do
    context "use_plugin_parser setting is true" do
      with_config(:use_plugin_parser, true)

      it 'should use timeliness' do
        Timeliness::Parser.should_receive(:parse)
        parse('2000-01-01')
      end
    end

    context "use_plugin_parser setting is false" do
      with_config(:use_plugin_parser, false)

      it 'should use Time.zone.parse attribute is timezone aware' do
        @timezone_aware = true
        Time.zone.should_receive(:parse)
        parse('2000-01-01')
      end

      it 'should use value#to_time if use_plugin_parser setting is false and attribute is not timezone aware' do
        @timezone_aware = false
        value = '2000-01-01'
        value.should_receive(:to_time)
        parse(value)
      end
    end

    it 'should return nil if value is nil' do
      parse(nil).should be_nil
    end
  end
end
