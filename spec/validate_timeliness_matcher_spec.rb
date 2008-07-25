require File.dirname(__FILE__) + '/spec_helper'

describe Spec::Rails::Matchers, "ValidateTimeliness matcher" do
  attr_accessor :no_validation, :with_validation
  
  before do
    class Person < ActiveRecord::Base
      alias_attribute :birth_datetime, :birth_date_and_time
    end
    
    class PersonWithValidations < Person
      validates_date :birth_date, :before => '2000-01-10', :after => '2000-01-01'
      validates_time :birth_time, :before => '23:00', :after => '09:00'
      validates_datetime :birth_date_and_time, :before => '2000-01-10 23:00', :after => '2000-01-01 09:00'
      
      alias_attribute :birth_datetime, :birth_date_and_time
    end
    @no_validation = Person.new
    @with_validation = PersonWithValidations.new
  end

  [:date, :time, :datetime].each do |type|
    attribute = type == :datetime ? :date_and_time : type
    
    it "should correctly report that #{type} is validated" do
      with_validation.should self.send("validate_#{type}", "birth_#{attribute}".to_sym)
    end
    
    it "should correctly report that #{type} is not validated" do
      no_validation.should_not self.send("validate_#{type}", "birth_#{attribute}".to_sym)
    end    
  end
   
  describe "with before option" do
    test_values = {
      :date     => ['2000-01-10', '2000-01-11'],
      :time     => ['23:00', '22:59'],
      :datetime => ['2000-01-10 23:00', '2000-01-10 22:59']  
    }
    
    [:date, :time, :datetime].each do |type|
      attribute = type == :datetime ? :date_and_time : type

      it "should correctly report that #{type} is validated" do
        with_validation.should self.send("validate_#{type}", "birth_#{attribute}", :before => test_values[type][0])
      end
      
      it "should correctly report that #{type} is not validated when option value is incorrect" do
        with_validation.should_not self.send("validate_#{type}", "birth_#{attribute}", :before => test_values[type][1])
      end
      
      it "should correctly report that #{type} is not validated with option" do
        no_validation.should_not self.send("validate_#{type}", "birth_#{attribute}", :before => test_values[type][0])
      end
    end
  end
    
  describe "with after option" do
    test_values = {
      :date     => ['2000-01-01', '2000-01-02'],
      :time     => ['09:00', '09:01'],
      :datetime => ['2000-01-01 09:00', '2000-01-01 09:01']  
    }
    
    [:date, :time, :datetime].each do |type|
      attribute = type == :datetime ? :date_and_time : type

      it "should correctly report that #{type} is validated" do
        with_validation.should self.send("validate_#{type}", "birth_#{attribute}", :after => test_values[type][0])
      end
      
      it "should correctly report that #{type} is not validated when option value is incorrect" do
        with_validation.should_not self.send("validate_#{type}", "birth_#{attribute}", :after => test_values[type][1])
      end
      
      it "should correctly report that #{type} is not validated with option" do
        no_validation.should_not self.send("validate_#{type}", "birth_#{attribute}", :after => test_values[type][0])
      end
    end
  end
  
#  describe "with on_or_before option" do
#    test_values = {
#      :date     => ['2000-01-01', '2000-01-02'],
#      :time     => ['09:00', '09:01'],
#      :datetime => ['2000-01-01 09:00', '2000-01-01 09:01']  
#    }
#    
#    [:date, :time, :datetime].each do |type|
#      attribute = type == :datetime ? :date_and_time : type

#      it "should correctly report that #{type} is validated" do
#        with_validation.should self.send("validate_#{type}", "birth_#{attribute}", :after => test_values[type][0])
#      end
#      
#      it "should correctly report that #{type} is not validated when option value is incorrect" do
#        with_validation.should_not self.send("validate_#{type}", "birth_#{attribute}", :after => test_values[type][1])
#      end
#      
#      it "should correctly report that #{type} is not validated with option" do
#        no_validation.should_not self.send("validate_#{type}", "birth_#{attribute}", :after => test_values[type][0])
#      end
#    end
#  end
end
