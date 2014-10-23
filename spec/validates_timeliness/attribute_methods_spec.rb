require 'spec_helper'

describe ValidatesTimeliness::AttributeMethods do
  it 'should define _timeliness_raw_value_for instance method' do
    expect(PersonWithShim.new).to respond_to(:_timeliness_raw_value_for)
  end

  describe ".timeliness_validated_attributes" do
    it 'should return attributes validated with plugin validator' do
      PersonWithShim.timeliness_validated_attributes = []
      PersonWithShim.validates_date :birth_date
      PersonWithShim.validates_time :birth_time
      PersonWithShim.validates_datetime :birth_datetime

      expect(PersonWithShim.timeliness_validated_attributes).to eq([ :birth_date, :birth_time, :birth_datetime ])
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
      expect(r._timeliness_raw_value_for('birth_datetime')).to eq(date_string)
    end

    it 'should not overwrite user defined methods' do
      e = Employee.new
      e.birth_date = '2010-01-01'
      expect(e.redefined_birth_date_called).to be_truthy
    end

    it 'should be undefined if model class has dynamic attribute methods reset' do
      # Force method definitions
      PersonWithShim.validates_date :birth_date
      r = PersonWithShim.new
      r.birth_date = Time.now

      write_method = RUBY_VERSION < '1.9' ? 'birth_date=' : :birth_date=

      expect(PersonWithShim.send(:generated_timeliness_methods).instance_methods).to include(write_method)

      PersonWithShim.undefine_attribute_methods

      expect(PersonWithShim.send(:generated_timeliness_methods).instance_methods).not_to include(write_method)
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
        expect(Timeliness::Parser).to receive(:parse)
        r = PersonWithParser.new
        r.birth_date = '2010-01-01'
      end

    end
  end

  context "before_type_cast method" do
    it 'should not be defined if ORM does not support it' do
      expect(PersonWithShim.new).not_to respond_to(:birth_datetime_before_type_cast)
    end
  end
end
