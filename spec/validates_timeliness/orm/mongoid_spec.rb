require 'spec_helper'

# Try loading mongoid and connecting. Otherwise, abort and skip spec.
begin

require 'mongoid'
require 'validates_timeliness/orm/mongoid'

Mongoid.configure do |config|
  name = "validates_timeliness_test"
  host = "localhost"
  config.master = Mongo::Connection.new.db(name)
  config.persist_in_safe_mode = false
end

describe ValidatesTimeliness, 'Mongoid' do

  class Article
    include Mongoid::Document
    field :publish_date, :type => Date
    field :publish_time, :type => Time
    field :publish_datetime, :type => DateTime
    validates_date :publish_date, :allow_nil => true
    validates_time :publish_time, :allow_nil => true
    validates_datetime :publish_datetime, :allow_nil => true
  end

  context "validation methods" do
    let(:record) { Article.new }

    it 'should be defined on the class' do
      Article.should respond_to(:validates_date)
      Article.should respond_to(:validates_time)
      Article.should respond_to(:validates_datetime)
    end

    it 'should be defined on the instance' do
      record.should respond_to(:validates_date)
      record.should respond_to(:validates_time)
      record.should respond_to(:validates_datetime)
    end

    it "should validate a valid value string" do
      record.publish_date = '2012-01-01'

      record.valid?
      record.errors[:publish_date].should be_empty
    end

    it "should validate a invalid value string" do
      begin
        record.publish_date = 'not a date' 
      rescue
      end

      record.valid?
      record.errors[:publish_date].should_not be_empty
    end

    it "should validate a nil value" do
      record.publish_date = nil

      record.valid?
      record.errors[:publish_date].should be_empty
    end
  end

  it 'should determine type for attribute' do
    Article.timeliness_attribute_type(:publish_date).should == :date
  end
  
  context "attribute write method" do
    let(:record) { Article.new }

    it 'should cache attribute raw value' do
      record.publish_datetime = date_string = '2010-01-01'

      record._timeliness_raw_value_for('publish_datetime').should == date_string
    end

    context "with plugin parser" do
      let(:record) { ArticleWithParser.new }

      class ArticleWithParser
        include Mongoid::Document
        field :publish_date, :type => Date
        field :publish_time, :type => Time
        field :publish_datetime, :type => DateTime

        ValidatesTimeliness.use_plugin_parser = true
        validates_date :publish_date, :allow_nil => true
        validates_time :publish_time, :allow_nil => true
        validates_datetime :publish_datetime, :allow_nil => true
        ValidatesTimeliness.use_plugin_parser = false
      end

      context "for a date column" do
        it 'should parse a string value' do
          Timeliness::Parser.should_receive(:parse)

          record.publish_date = '2010-01-01'
        end

        it 'should parse a invalid string value as nil' do
          Timeliness::Parser.should_receive(:parse)

          record.publish_date = 'not valid'
        end

        it 'should store a Date value after parsing string' do
          record.publish_date = '2010-01-01'

          record.publish_date.should be_kind_of(Date)
          record.publish_date.should eq Date.new(2010, 1, 1)
        end
      end

      context "for a time column" do
        it 'should parse a string value' do
          Timeliness::Parser.should_receive(:parse)

          record.publish_time = '12:30'
        end

        it 'should parse a invalid string value as nil' do
          Timeliness::Parser.should_receive(:parse)

          record.publish_time = 'not valid'
        end

        it 'should store a Time value after parsing string' do
          record.publish_time = '12:30'

          record.publish_time.should be_kind_of(Time)
          record.publish_time.should eq Time.utc(2000, 1, 1, 12, 30)
        end
      end

      context "for a datetime column" do
        with_config(:default_timezone, 'Australia/Melbourne')

        it 'should parse a string value' do
          Timeliness::Parser.should_receive(:parse)

          record.publish_datetime = '2010-01-01 12:00'
        end

        it 'should parse a invalid string value as nil' do
          Timeliness::Parser.should_receive(:parse)

          record.publish_datetime = 'not valid'
        end

        it 'should parse string into DateTime value' do
          record.publish_datetime = '2010-01-01 12:00'

          record.publish_datetime.should be_kind_of(DateTime)
        end

        pending 'should parse string as current timezone' do
          record.publish_datetime = '2010-06-01 12:00'

          record.publish_datetime.utc_offset.should eq Time.zone.utc_offset
        end
      end
    end
  end

  context "cached value" do
    it 'should be cleared on reload' do
      record = Article.create!
      record.publish_date = '2010-01-01'
      record.reload
      record._timeliness_raw_value_for('publish_date').should be_nil
    end
  end

  context "before_type_cast method" do
    it 'should not be defined if ORM does not support it' do
      Article.new.should_not respond_to(:publish_datetime_before_type_cast)
    end
  end
end

rescue LoadError
  puts "Mongoid specs skipped. Mongoid not installed"
rescue StandardError => e
  puts "Mongoid specs skipped. MongoDB connection failed with error: #{e.message}"
end
