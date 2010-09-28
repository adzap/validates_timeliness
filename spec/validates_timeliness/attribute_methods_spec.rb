require 'spec_helper'

describe ValidatesTimeliness::AttributeMethods do
  it 'should define _timeliness_raw_value_for instance method' do
    PersonWithShim.instance_methods.should include('_timeliness_raw_value_for')
  end

  describe ".timeliness_validated_attributes" do
    it 'should return attributes validated with plugin validator' do
      PersonWithShim.timeliness_validated_attributes = []
      PersonWithShim.validates_date :birth_date
      PersonWithShim.validates_time :birth_time
      PersonWithShim.validates_datetime :birth_datetime

      PersonWithShim.timeliness_validated_attributes.should == [ :birth_date, :birth_time, :birth_datetime ]
    end
  end
  
  context "attribute write method" do
    class PersonWithCache
      include TestModel
      include TestModelShim
      attribute :birth_date, :date
      attribute :birth_time, :time
      attribute :birth_datetime, :datetime
      validates_date :birth_date
      validates_time :birth_time
      validates_datetime :birth_datetime
    end

    it 'should cache attribute raw value' do
      r = PersonWithCache.new
      r.birth_datetime = date_string = '2010-01-01'
      r._timeliness_raw_value_for(:birth_datetime).should == date_string
    end

    context "with plugin parser" do
      class PersonWithParser
        include TestModel
        include TestModelShim
        attribute :birth_date, :date
        attribute :birth_time, :time
        attribute :birth_datetime, :datetime
        validates_date :birth_date
        validates_time :birth_time
        validates_datetime :birth_datetime
      end

      before :all do
        ValidatesTimeliness.use_plugin_parser = true
      end

      it 'should parse a string value' do
        ValidatesTimeliness::Parser.should_receive(:parse) 
        r = PersonWithParser.new
        r.birth_date = '2010-01-01'
      end

      it 'should parse string as current timezone' do
        r = PersonWithParser.new
        r.birth_datetime = '2010-01-01 12:00'
        r.birth_datetime.zone == Time.zone.name
      end

      after :all do
        ValidatesTimeliness.use_plugin_parser = false
      end
    end
  end

  context "before_type_cast method" do
    it 'should not be defined if ORM does not support it' do
      PersonWithShim.instance_methods(false).should_not include("birth_datetime_before_type_cast")
    end
  end
end
