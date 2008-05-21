require File.dirname(__FILE__) + '/spec_helper'

describe ValidatesTimeliness::Base do

  class AttributeAssignmentError;       def initialize(*args); end; end
  class MultiparameterAssignmentErrors; def initialize(*args); end; end

  before do
    self.class.stub!(:reflect_on_aggregation).and_return(nil)
    
  end  

  it "should convert time array into string" do
    time_string = time_array_to_string([2000,1,1,12,12,0])
    time_string.should == "2000-01-01 12:12:00"
  end
  
  describe "execute_callstack_for_multiparameter_attributes" do 
    before do
      @date_array = [1980,1,1,0,0,0]
    end
  
    it "should store time string for a Time class column" do      
      self.stub!(:column_for_attribute).and_return( mock('Column', :klass => Time) )
      self.should_receive(:birth_date_and_time=).once.with("1980-01-01 00:00:00")
      callstack = {'birth_date_and_time' => @date_array}
      execute_callstack_for_multiparameter_attributes(callstack)
    end    
    
    it "should store time string for a Date class column" do
      self.stub!(:column_for_attribute).and_return( mock('Column', :klass => Date) )
      self.should_receive(:birth_date=).once.with("1980-01-01 00:00:00")
      callstack = {'birth_date' => @date_array}
      execute_callstack_for_multiparameter_attributes(callstack)
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
end
