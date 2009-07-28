require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ValidatesTimeliness::ActiveRecord::MultiparameterAttributes do
  def obj
    @obj ||= Person.new
  end

  it "should convert array for datetime type into datetime string" do
    time_string = time_array_to_string([2000,2,1,9,10,11], :datetime)
    time_string.should == "2000-02-01 09:10:11"
  end
  
  it "should convert array for date type into date string" do
    time_string = time_array_to_string([2000,2,1], :date)
    time_string.should == "2000-02-01"
  end
  
  it "should convert array for time type into time string" do
    time_string = time_array_to_string([2000,1,1,9,10,11], :time)
    time_string.should == "09:10:11"
  end
  
  describe "execute_callstack_for_multiparameter_attributes" do 
    before do      
      @callstack = {
        'birth_date_and_time' => [2000,2,1,9,10,11],
        'birth_date' => [2000,2,1,9,10,11],
        'birth_time' => [2000,2,1,9,10,11]
      }
    end
    
    it "should store datetime string for datetime column" do      
      obj.should_receive(:birth_date_and_time=).once.with("2000-02-01 09:10:11")
      obj.send(:execute_callstack_for_multiparameter_attributes, @callstack)
    end    
    
    it "should store date string for a date column" do
      obj.should_receive(:birth_date=).once.with("2000-02-01")
      obj.send(:execute_callstack_for_multiparameter_attributes, @callstack)
    end
   
    it "should store time string for a time column" do
      obj.should_receive(:birth_time=).once.with("09:10:11")
      obj.send(:execute_callstack_for_multiparameter_attributes, @callstack)
    end
  end

  def time_array_to_string(*args)
    ValidatesTimeliness::ActiveRecord.time_array_to_string(*args)
  end
  
end
