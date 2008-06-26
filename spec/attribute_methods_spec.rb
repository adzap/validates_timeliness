require File.dirname(__FILE__) + '/spec_helper'

describe ValidatesTimeliness::AttributeMethods do
  include ValidatesTimeliness::AttributeMethods
  
  before do
    @person = Person.new
  end
  
  describe "read_attribute" do
    it "should return time object from time string" do
      @attributes = {}
      self.stub!(:column_for_attribute).and_return( mock('Column', :klass => Time) )
      self.stub!(:unserializable_attribute?).and_return(false)
      
      @attributes['birth_date_and_time'] = "1980-01-01 00:00:00"
      read_attribute(:birth_date_and_time).should be_kind_of(Time)
    end

    it "should return nil from invalid time string" do
      @attributes = {}
      self.stub!(:column_for_attribute).and_return( mock('Column', :klass => Time) )
      self.stub!(:unserializable_attribute?).and_return(false)
      
      @attributes['birth_date_and_time'] = "1980-02-30 00:00:00"
      read_attribute(:birth_date_and_time).should be_nil
    end
  end
  
  describe "strict_time_type_cast" do
    it "should return time object for valid time string" do
      strict_time_type_cast("2000-01-01 12:13:14").should be_kind_of(Time)
    end
    
    it "should return nil for time string with invalid date part" do
      strict_time_type_cast("2000-02-30 12:13:14").should be_nil
    end
    
    it "should return nil for time string with invalid time part" do
      strict_time_type_cast("2000-02-01 25:13:14").should be_nil      
    end
    
    it "should return time object for time object" do
      strict_time_type_cast(Time.now).should be_kind_of(Time)
    end
    
    if RAILS_VER >= '2.1'
      it "should convert time string into current timezone" do
        time = strict_time_type_cast("2000-01-01 12:13:14")
        Time.zone.utc_offset.should == 0
        time.zone.should == 'UTC'
      end
    end
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
 
  # This fails running as plugin under vendor using Rails 2.1RC
  # due to write_attribute_with_dirty ignoring the write method for time zone
  # method. But invalid dates do return nil when running app.
  it "should return nil when time is invalid" do
    @person.birth_date_and_time = "2000-02-30 01:02:03"
    @person.birth_date_and_time.should be_nil
  end

  unless RAILS_VER < '2.1'
    it "should return stored time string as Time with correct timezone" do
      Time.zone = 'Melbourne'
      time_string = "2000-06-01 01:02:03"
      @person.birth_date_and_time = time_string
      @person.birth_date_and_time.utc_offset.should == 10.hours
      @person.birth_date_and_time.strftime('%Y-%m-%d %H:%M:%S').should == time_string
    end
  end
  
  describe "time attribute persistance" do
    unless RAILS_VER < '2.1'
      it "should return time object from database in correct timezone" do        
        Time.zone = 'Melbourne'
        time_string = "1980-06-01 09:00:00"
        @person = Person.new
        @person.birth_date_and_time = time_string
        @person.save
        @person.reload
        @person.birth_date_and_time.to_s.should == time_string
      end
    end
  end
 
end
