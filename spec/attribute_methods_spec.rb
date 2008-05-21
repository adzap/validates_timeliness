require File.dirname(__FILE__) + '/spec_helper'

describe ValidatesTimeliness::AttributeMethods do
 
  describe "for Time columns" do
    before do
      @person = Person.new
    end

    it "should return string value for attribute_before_type_cast when written as string" do
      time_string = "2000-06-01 01:02:03"
      @person.birth_date_and_time = time_string
      @person.birth_date_and_time_before_type_cast.should == time_string
    end
    
    it "should return Time object for attribute_before_type_cast when written as Time" do
      @person.birth_date_and_time = Time.mktime(2000, 06, 01, 1, 2, 3)
      @person.birth_date_and_time_before_type_cast.should be_kind_of(Time)
    end

    it "should return Time object using attribute read method when written with string" do
      @person.birth_date_and_time = "2000-06-01 01:02:03"
      @person.birth_date_and_time.should be_kind_of(Time)
    end    
   
    unless Rails::VERSION::STRING <= '2.0.2'
      it "should return stored time string as Time with correct timezone" do
        Time.zone = TimeZone['Melbourne']
        time_string = "2000-06-01 01:02:03"
        @person.birth_date_and_time = time_string
        @person.birth_date_and_time.utc_offset.should == 10.hours
        @person.birth_date_and_time.strftime('%Y-%m-%d %H:%M:%S').should == time_string
      end
    end
    
    it "should return nil when time is invalid" do
      @person.birth_date_and_time = "2000-02-30 01:02:03"
      @person.birth_date_and_time.should be_nil
    end   
    
  end
end
