require File.dirname(__FILE__) + '/spec_helper'

describe ValidatesTimeliness::AttributeMethods do
 
  describe "for Time columns" do
    before do
      @person = Person.new
    end

    it "should return string value for attribute_before_type_cast when written as string" do
      @person.birth_date_and_time = "1980-12-25 01:02:03"
      @person.birth_date_and_time_before_type_cast.should == "1980-12-25 01:02:03"
    end
    
    it "should return Time object for attribute_before_type_cast when written as Time" do
      @person.birth_date_and_time = Time.mktime(1980, 12, 25, 1, 2, 3)
      @person.birth_date_and_time_before_type_cast.should be_kind_of(Time)
    end

    it "should return Time object using attribute read method when written with string" do
      @person.birth_date_and_time = "1980-12-25 01:02:03"
      @person.birth_date_and_time.should be_kind_of(Time)
    end    
   
    unless ActiveRecord::VERSION::STRING < '2.1'
      it "should return stored time string as Time with correct timezone" do
        Time.zone = TimeZone['Sydney'] # no I'm not from Sydney but there is no Melbourne timezone!
        @person.birth_date_and_time = "1980-12-25 01:02:03"
        @person.birth_date_and_time.zone == Time.zone
      end
    end
    
    it "should return nil when time is invalid" do
      @person.birth_date_and_time = "1980-02-30 01:02:03"
      @person.birth_date_and_time.should be_nil
    end   
    
  end
end
