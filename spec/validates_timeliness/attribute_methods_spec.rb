require 'spec_helper'

describe ValidatesTimeliness::AttributeMethods do
  it 'should define _timeliness_raw_value_for instance method' do
    PersonWithShim.new.should respond_to(:_timeliness_raw_value_for)
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
      r._timeliness_raw_value_for('birth_datetime').should == date_string
    end

    it 'should not overwrite user defined methods' do
      e = Employee.new
      e.birth_date = '2010-01-01'
      e.redefined_birth_date_called.should be_true
    end

    it 'should be undefined if model class has dynamic attribute methods reset' do
      # Force method definitions
      PersonWithShim.validates_date :birth_date
      r = PersonWithShim.new
      r.birth_date = Time.now

      write_method = RUBY_VERSION < '1.9' ? 'birth_date=' : :birth_date=

      PersonWithShim.send(:generated_timeliness_methods).instance_methods.should include(write_method)

      PersonWithShim.undefine_attribute_methods 

      PersonWithShim.send(:generated_timeliness_methods).instance_methods.should_not include(write_method)
    end

    context "with plugin parser" do
      with_config(:use_plugin_parser, true)

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

      it 'should parse a string value' do
        Timeliness::Parser.should_receive(:parse)
        r = PersonWithParser.new
        r.birth_date = '2010-01-01'
      end

    end
  end

  context "before_type_cast method" do
    it 'should not be defined if ORM does not support it' do
      PersonWithShim.new.should_not respond_to(:birth_datetime_before_type_cast)
    end
  end
end
