require File.dirname(__FILE__) + '/spec_helper'

describe ValidatesTimeliness::CoreExtensions::Date do  
  before do
    @a_date = Date.new(2008, 7, 1)
  end
  
  it "should " do
    @a_date.to_dummy_time.should == Time.mktime(2000,1,1,0,0,0)
  end
end

describe ValidatesTimeliness::CoreExtensions::Time do
  before do
    @a_time = Time.mktime(2008, 7, 1, 2, 3, 4)
  end
  
  it "should " do
    @a_time.to_dummy_time.should == Time.mktime(2000,1,1,2,3,4)
  end
end

describe ValidatesTimeliness::CoreExtensions::DateTime do
  before do
    @a_datetime = DateTime.new(2008, 7, 1, 2, 3, 4)
  end
  
  it "should " do
    @a_datetime.to_dummy_time.should == Time.mktime(2000,1,1,2,3,4)
  end
end
