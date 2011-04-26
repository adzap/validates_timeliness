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
    ::ValidatesTimeliness.use_plugin_parser = true
    include Mongoid::Document
    field :publish_date, :type => Date
    field :publish_time, :type => Time
    field :publish_datetime, :type => DateTime
    validates_date :publish_date, :allow_nil => true
    validates_time :publish_time, :allow_nil => true
    validates_datetime :publish_datetime, :allow_nil => true
    ::ValidatesTimeliness.use_plugin_parser = false
  end

  context "validation methods" do
    it 'should be defined on the class' do
      Article.should respond_to(:validates_date)
      Article.should respond_to(:validates_time)
      Article.should respond_to(:validates_datetime)
    end

    it 'should be defined on the instance' do
      Article.new.should respond_to(:validates_date)
      Article.new.should respond_to(:validates_time)
      Article.new.should respond_to(:validates_datetime)
    end
  end

  it 'should determine type for attribute' do
    Article.timeliness_attribute_type(:publish_date).should == :date
  end
  
  context "attribute write method" do
    it 'should cache attribute raw value' do
      r = Article.new
      r.publish_datetime = date_string = '2010-01-01'
      r._timeliness_raw_value_for(:publish_datetime).should == date_string
    end

    context "with plugin parser" do
      with_config(:use_plugin_parser, false)

      it 'should parse a string value' do
        Timeliness::Parser.should_receive(:parse)
        r = Article.new
        r.publish_date = '2010-01-01'
      end

      context "for a date column" do
        it 'should store a date value after parsing string' do
          r = Article.new
          r.publish_date = '2010-01-01'

          r.publish_date.should be_kind_of(Date)
          r.publish_date.should == Date.new(2010, 1, 1)
        end
      end

      context "for a datetime column" do
        it 'should parse string into Time value' do
          r = Article.new
          r.publish_datetime = '2010-01-01 12:00'

          r.publish_datetime.should be_kind_of(Time)
          r.publish_datetime.should == Time.utc(2010,1,1,12,0)
        end
      end
    end
  end

  context "cached value" do
    it 'should be cleared on reload' do
      r = Article.create!
      r.publish_date = '2010-01-01'
      r.reload
      r._timeliness_raw_value_for(:publish_date).should be_nil
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
rescue StandardError
  puts "Mongoid specs skipped. MongoDB connection failed."
end
