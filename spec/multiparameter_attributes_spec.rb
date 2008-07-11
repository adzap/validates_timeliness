require File.dirname(__FILE__) + '/spec_helper'

describe ValidatesTimeliness::MultiparameterAttributes do
  include ValidatesTimeliness::MultiparameterAttributes

  class AttributeAssignmentError;       def initialize(*args); end; end
  class MultiparameterAssignmentErrors; def initialize(*args); end; end

  before do
    self.class.stub!(:reflect_on_aggregation).and_return(nil)
  end  

  it "should convert time array into string" do
    time_string = time_array_to_string([2000,2,1,9,10,11])
    time_string.should == "2000-02-01 09:10:11"
  end
  
  describe "execute_callstack_for_multiparameter_attributes" do 
    before do
      @date_array = [2000,2,1,9,10,11]
    end
  
    it "should store time string for a Time class column" do      
      self.stub!(:column_for_attribute).and_return( mock('Column', :klass => Time) )
      self.should_receive(:birth_date_and_time=).once.with("2000-02-01 09:10:11")
      callstack = {'birth_date_and_time' => @date_array}
      execute_callstack_for_multiparameter_attributes(callstack)
    end    
    
    it "should store time string for a Date class column" do
      self.stub!(:column_for_attribute).and_return( mock('Column', :klass => Date) )
      self.should_receive(:birth_date=).once.with("2000-02-01 09:10:11")
      callstack = {'birth_date' => @date_array}
      execute_callstack_for_multiparameter_attributes(callstack)
    end
  end
  
end
