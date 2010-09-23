require 'spec_helper'

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
    validates_date :publish_date
    validates_time :publish_time
    validates_datetime :publish_datetime
    ::ValidatesTimeliness.use_plugin_parser = false
  end

  it 'should define class validation methods' do
    Article.should respond_to(:validates_date)
    Article.should respond_to(:validates_time)
    Article.should respond_to(:validates_datetime)
  end

  it 'should define instance validation methods' do
    Article.instance_methods.should include('validates_date')
    Article.instance_methods.should include('validates_time')
    Article.instance_methods.should include('validates_datetime')
  end

  it 'should define _timeliness_raw_value_for instance method' do
    Article.instance_methods.should include('_timeliness_raw_value_for')
  end
  
  context "attribute write method" do
    it 'should cache attribute raw value' do
      r = Article.new
      r.publish_datetime = date_string = '2010-01-01'
      r._timeliness_raw_value_for(:publish_datetime).should == date_string
    end

    context "with plugin parser" do
      before :all do
        ValidatesTimeliness.use_plugin_parser = true
      end

      it 'should parse a string value' do
        ValidatesTimeliness::Parser.should_receive(:parse) 
        r = Article.new
        r.publish_date = '2010-01-01'
      end

      it 'should parse string into Time value' do
        r = Article.new
        r.publish_datetime = '2010-01-01 12:00'
        r.publish_datetime.should == Time.utc(2010,1,1,12,0)
      end

      after :all do
        ValidatesTimeliness.use_plugin_parser = false
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
      Article.instance_methods(false).should_not include("birth_datetime_before_type_cast")
    end
  end
end
