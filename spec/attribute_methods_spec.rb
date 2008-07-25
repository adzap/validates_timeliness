require File.dirname(__FILE__) + '/spec_helper'

describe ValidatesTimeliness::AttributeMethods do
  include ValidatesTimeliness::AttributeMethods
  include ValidatesTimeliness::Validations
  
  before do
    @person = Person.new
  end

  it "should call parser on write for datetime attribute" do
    @person.class.should_receive(:parse_date_time).once
    @person.birth_date_and_time = "2000-01-01 02:03:04"
  end

  it "should call parser on write for date attribute" do
    @person.class.should_receive(:parse_date_time).once
    @person.birth_date = "2000-01-01"
  end

  it "should call parser on write for time attribute" do
    @person.class.should_receive(:parse_date_time).once
    @person.birth_time = "12:00"
  end

  it "should return raw string value for attribute_before_type_cast when written as string" do
    time_string = "2000-01-01 02:03:04"
    @person.birth_date_and_time = time_string
    @person.birth_date_and_time_before_type_cast.should == time_string
  end
  
  it "should return Time object for attribute_before_type_cast when written as Time" do
    @person.birth_date_and_time = Time.mktime(2000, 1, 1, 2, 3, 4)
    @person.birth_date_and_time_before_type_cast.should be_kind_of(Time)
  end

  it "should return Time object using attribute read method when written with string" do
    @person.birth_date_and_time = "2000-01-01 02:03:04"
    @person.birth_date_and_time.should be_kind_of(Time)
  end    
 
  it "should return nil when time is invalid" do
    @person.birth_date_and_time = "2000-01-32 02:03:04"
    @person.birth_date_and_time.should be_nil
  end

  it "should not save invalid date value to database" do        
    time_string = "2000-01-32 02:03:04"
    @person = Person.new
    @person.birth_date_and_time = time_string
    @person.save
    @person.reload
    @person.birth_date_and_time_before_type_cast.should be_nil
  end
  
  unless RAILS_VER < '2.1'
    it "should return stored time string as Time with correct timezone" do
      Time.zone = 'Melbourne'
      time_string = "2000-06-01 02:03:04"
      @person.birth_date_and_time = time_string
      @person.birth_date_and_time.strftime('%Y-%m-%d %H:%M:%S %Z %z').should == time_string + ' EST +1000'
    end

    it "should return time object from database in correct timezone" do        
      Time.zone = 'Melbourne'
      time_string = "2000-06-01 09:00:00"
      @person = Person.new
      @person.birth_date_and_time = time_string
      @person.save
      @person.reload
      @person.birth_date_and_time.strftime('%Y-%m-%d %H:%M:%S %Z %z').should == time_string + ' EST +1000'
    end
    
    it "should return true for attribute changed?" do
      time_string = "2000-01-01 02:03:04"
      @person.birth_date_and_time = time_string
      @person.birth_date_and_time_changed?.should be_true
    end
    
    it "should show changes for time attribute as nil to Time object" do
      time_string = "2000-01-01 02:03:04"
      @person.birth_date_and_time = time_string
      time = @person.birth_date_and_time
      @person.changes.should == {"birth_date_and_time" => [nil, time]}
    end
    
  else
    
    it "should return time object from database in default timezone" do        
      ActiveRecord::Base.default_timezone = :utc
      time_string = "2000-01-01 09:00:00"
      @person = Person.new
      @person.birth_date_and_time = time_string
      @person.save
      @person.reload
      @person.birth_date_and_time.strftime('%Y-%m-%d %H:%M:%S %Z').should == time_string + ' GMT'
    end
      
  end
  
  it "should return same time object on repeat reads" do
    Time.zone = 'Melbourne' unless RAILS_VER < '2.1'
    time_string = "2000-01-01 09:00:00"
    @person = Person.new
    @person.birth_date_and_time = time_string
    @person.save
    @person.reload
    time = @person.birth_date_and_time
    @person.birth_date_and_time.should == time
  end
 
end
