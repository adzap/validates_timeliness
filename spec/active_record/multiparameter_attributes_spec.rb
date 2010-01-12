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

    describe "for valid values" do
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

    describe "for invalid values" do
      before do
        @callstack = {
          'birth_date_and_time' => [2000,13,1,9,10,11],
          'birth_date' => [2000,2,41,9,10,11],
          'birth_time' => [2000,2,1,25,10,11]
        }
      end

      it "should store invalid datetime string for datetime column" do
        obj.should_receive(:birth_date_and_time=).once.with("2000-13-01 09:10:11")
        obj.send(:execute_callstack_for_multiparameter_attributes, @callstack)
      end

      it "should store invalid date string for a date column" do
        obj.should_receive(:birth_date=).once.with("2000-02-41")
        obj.send(:execute_callstack_for_multiparameter_attributes, @callstack)
      end

      it "should store invalid time string for a time column" do
        obj.should_receive(:birth_time=).once.with("25:10:11")
        obj.send(:execute_callstack_for_multiparameter_attributes, @callstack)
      end
    end

    describe "for missing values" do
      it "should store nil if all datetime values nil" do
        obj.should_receive(:birth_date_and_time=).once.with(nil)
        callstack = { 'birth_date_and_time' => [nil,nil,nil,nil,nil,nil] }
        obj.send(:execute_callstack_for_multiparameter_attributes, callstack)
      end

      it "should store nil year as empty value in string" do
        obj.should_receive(:birth_date_and_time=).once.with("-02-01 09:10:11")
        callstack = { 'birth_date_and_time' => [nil,2,1,9,10,11] }
        obj.send(:execute_callstack_for_multiparameter_attributes, callstack)
      end

      it "should store nil month as empty value in string" do
        obj.should_receive(:birth_date_and_time=).once.with("2000--01 09:10:11")
        callstack = { 'birth_date_and_time' => [2000,nil,1,9,10,11] }
        obj.send(:execute_callstack_for_multiparameter_attributes, callstack)
      end

      it "should store nil day as empty value in string" do
        obj.should_receive(:birth_date_and_time=).once.with("2000-02- 09:10:11")
        callstack = { 'birth_date_and_time' => [2000,2,nil,9,10,11] }
        obj.send(:execute_callstack_for_multiparameter_attributes, callstack)
      end

      it "should store nil hour as empty value in string" do
        obj.should_receive(:birth_date_and_time=).once.with("2000-02-01 :10:11")
        callstack = { 'birth_date_and_time' => [2000,2,1,nil,10,11] }
        obj.send(:execute_callstack_for_multiparameter_attributes, callstack)
      end

      it "should store nil minute as empty value in string" do
        obj.should_receive(:birth_date_and_time=).once.with("2000-02-01 09:10:")
        callstack = { 'birth_date_and_time' => [2000,2,1,9,10,nil] }
        obj.send(:execute_callstack_for_multiparameter_attributes, callstack)
      end
    end
  end

  def time_array_to_string(*args)
    ValidatesTimeliness::ActiveRecord.time_array_to_string(*args)
  end

end
