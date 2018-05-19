RSpec.describe ValidatesTimeliness::Converter do
  subject(:converter) { described_class.new(type: type, time_zone_aware: time_zone_aware, ignore_usec: ignore_usec) }

  let(:options) { Hash.new }
  let(:type) { :date }
  let(:time_zone_aware) { false }
  let(:ignore_usec) { false }

  before do
    Timecop.freeze(Time.mktime(2010, 1, 1, 0, 0, 0))
  end

  delegate :type_cast_value, :evaluate, :parse, :dummy_time, to: :converter

  describe "#type_cast_value" do
    describe "for date type" do
      let(:type) { :date }

      it "should return same value for date value" do
        expect(type_cast_value(Date.new(2010, 1, 1))).to eq(Date.new(2010, 1, 1))
      end

      it "should return date part of time value" do
        expect(type_cast_value(Time.mktime(2010, 1, 1, 0, 0, 0))).to eq(Date.new(2010, 1, 1))
      end

      it "should return date part of datetime value" do
        expect(type_cast_value(DateTime.new(2010, 1, 1, 0, 0, 0))).to eq(Date.new(2010, 1, 1))
      end

      it 'should return nil for invalid value types' do
        expect(type_cast_value(12)).to eq(nil)
      end
    end

    describe "for time type" do
      let(:type) { :time }

      it "should return same value for time value matching dummy date part" do
        expect(type_cast_value(Time.utc(2000, 1, 1, 0, 0, 0))).to eq(Time.utc(2000, 1, 1, 0, 0, 0))
      end

      it "should return dummy time value with same time part for time value with different date" do
        expect(type_cast_value(Time.utc(2010, 1, 1, 0, 0, 0))).to eq(Time.utc(2000, 1, 1, 0, 0, 0))
      end

      it "should return dummy time only for date value" do
        expect(type_cast_value(Date.new(2010, 1, 1))).to eq(Time.utc(2000, 1, 1, 0, 0, 0))
      end

      it "should return dummy date with time part for datetime value" do
        expect(type_cast_value(DateTime.civil_from_format(:utc, 2010, 1, 1, 12, 34, 56))).to eq(Time.utc(2000, 1, 1, 12, 34, 56))
      end

      it 'should return nil for invalid value types' do
        expect(type_cast_value(12)).to eq(nil)
      end
    end

    describe "for datetime type" do
      let(:type) { :datetime }
      let(:time_zone_aware) { true }

      it "should return Date as Time value" do
        expect(type_cast_value(Date.new(2010, 1, 1))).to eq(Time.local(2010, 1, 1, 0, 0, 0))
      end

      it "should return same Time value" do
        value = Time.utc(2010, 1, 1, 12, 34, 56)
        expect(type_cast_value(Time.utc(2010, 1, 1, 12, 34, 56))).to eq(value)
      end

      it "should return as Time with same component values" do
        expect(type_cast_value(DateTime.civil_from_format(:utc, 2010, 1, 1, 12, 34, 56))).to eq(Time.utc(2010, 1, 1, 12, 34, 56))
      end

      it "should return same Time in correct zone if timezone aware" do
        value = Time.utc(2010, 1, 1, 12, 34, 56)
        result = type_cast_value(value)
        expect(result).to eq(Time.zone.local(2010, 1, 1, 23, 34, 56))
        expect(result.zone).to eq('AEDT')
      end

      it 'should return nil for invalid value types' do
        expect(type_cast_value(12)).to eq(nil)
      end
    end

    describe "ignore_usec option" do
      let(:type) { :datetime }
      let(:ignore_usec) { true }

      it "should ignore usec on time values when evaluated" do
        value = Time.utc(2010, 1, 1, 12, 34, 56, 10000)
        expect(type_cast_value(value)).to eq(Time.utc(2010, 1, 1, 12, 34, 56))
      end

      context do
        let(:time_zone_aware) { true }

        it "should ignore usec and return time in correct zone if timezone aware" do
          value = Time.utc(2010, 1, 1, 12, 34, 56, 10000)
          result = type_cast_value(value)
          expect(result).to eq(Time.zone.local(2010, 1, 1, 23, 34, 56))
          expect(result.zone).to eq('AEDT')
        end
      end
    end
  end

  describe "#dummy_time" do
    it 'should return Time with dummy date values but same time components' do
      expect(dummy_time(Time.utc(2010, 11, 22, 12, 34, 56))).to eq(Time.utc(2000, 1, 1, 12, 34, 56))
    end

    it 'should return same value for Time which already has dummy date values' do
      expect(dummy_time(Time.utc(2000, 1, 1, 12, 34, 56))).to eq(Time.utc(2000, 1, 1, 12, 34, 56))
    end

    it 'should return time component values shifted to current zone if timezone aware' do
      expect(dummy_time(Time.utc(2000, 1, 1, 12, 34, 56))).to eq(Time.zone.local(2000, 1, 1, 23, 34, 56))
    end

    it 'should return base dummy time value for Date value' do
      expect(dummy_time(Date.new(2010, 11, 22))).to eq(Time.utc(2000, 1, 1, 0, 0, 0))
    end

    describe "with custom dummy date" do
      it 'should return dummy time with custom dummy date' do
        with_config(:dummy_date_for_time_type, [2010, 1, 1] ) do
          expect(dummy_time(Time.utc(1999, 11, 22, 12, 34, 56))).to eq(Time.utc(2010, 1, 1, 12, 34, 56))
        end
      end
    end
  end

  describe "#evaluate" do
    let(:person) { Person.new }

    it 'should return Date object as is' do
      value = Date.new(2010,1,1)
      expect(evaluate(value, person)).to eq(value)
    end

    it 'should return Time object as is' do
      value = Time.mktime(2010,1,1)
      expect(evaluate(value, person)).to eq(value)
    end

    it 'should return DateTime object as is' do
      value = DateTime.new(2010,1,1,0,0,0)
      expect(evaluate(value, person)).to eq(value)
    end

    it 'should return Time value returned from proc with 0 arity' do
      value = Time.mktime(2010,1,1)
      expect(evaluate(lambda { value }, person)).to eq(value)
    end

    it 'should return Time value returned by record attribute call in proc arity of 1' do
      value = Time.mktime(2010,1,1)
      person.birth_time = value
      expect(evaluate(lambda {|r| r.birth_time }, person)).to eq(value)
    end

    it 'should return Time value for attribute method symbol which returns Time' do
      value = Time.mktime(2010,1,1)
      person.birth_datetime = value
      expect(evaluate(:birth_datetime, person)).to eq(value)
    end

    it 'should return Time value is default zone from string time value' do
      value = '2010-01-01 12:00:00'
      expect(evaluate(value, person)).to eq(Time.utc(2010,1,1,12,0,0))
    end

    context do
      let(:converter) { described_class.new(type: :date, time_zone_aware: true) }

      it 'should return Time value is current zone from string time value if timezone aware' do
        value = '2010-01-01 12:00:00'
        expect(evaluate(value, person)).to eq(Time.zone.local(2010,1,1,12,0,0))
      end
    end

    it 'should return Time value in default zone from proc which returns string time' do
      value = '2010-11-12 13:00:00'
      expect(evaluate(lambda { value }, person)).to eq(Time.utc(2010,11,12,13,0,0))
    end

    it 'should return Time value for attribute method symbol which returns string time value' do
      value = '13:00:00'
      person.birth_time = value
      expect(evaluate(:birth_time, person)).to eq(Time.utc(2000,1,1,13,0,0))
    end

    context "restriction shorthand" do
      before do
        Timecop.freeze(Time.mktime(2010, 1, 1, 0, 0, 0))
      end

      it 'should evaluate :now as current time' do
        expect(evaluate(:now, person)).to eq(Time.now)
      end

      it 'should evaluate :today as current time' do
        expect(evaluate(:today, person)).to eq(Date.today)
      end

      it 'should not use shorthand if symbol if is record method' do
        time = 1.day.from_now
        allow(person).to receive(:now).and_return(time)
        expect(evaluate(:now, person)).to eq(time)
      end
    end
  end

  describe "#parse" do
    context "use_plugin_parser setting is true" do
      with_config(:use_plugin_parser, true)

      it 'should use timeliness' do
        expect(Timeliness::Parser).to receive(:parse)
        parse('2000-01-01')
      end
    end

    context "use_plugin_parser setting is false" do
      with_config(:use_plugin_parser, false)

      it 'should use Time.zone.parse attribute is timezone aware' do
        expect(Timeliness::Parser).to_not receive(:parse)
        parse('2000-01-01')
      end

      it 'should use value#to_time if use_plugin_parser setting is false and attribute is not timezone aware' do
        value = '2000-01-01'
        expect(value).to receive(:to_time)
        parse(value)
      end
    end

    it 'should return nil if value is nil' do
      expect(parse(nil)).to be_nil
    end
  end
end
