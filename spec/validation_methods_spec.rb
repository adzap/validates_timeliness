require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe ValidatesTimeliness::ValidationMethods do
  attr_accessor :person

  describe "parse_date_time" do
    it "should return time object for valid time string" do
      parse_method("2000-01-01 12:13:14", :datetime).should be_kind_of(Time)
    end
    
    it "should return nil for time string with invalid date part" do
      parse_method("2000-02-30 12:13:14", :datetime).should be_nil
    end
    
    it "should return nil for time string with invalid time part" do
      parse_method("2000-02-01 25:13:14", :datetime).should be_nil      
    end
    
    it "should return Time object when passed a Time object" do
      parse_method(Time.now, :datetime).should be_kind_of(Time)
    end
        
    if RAILS_VER >= '2.1'
      it "should convert time string into current timezone" do
        Time.zone = 'Melbourne'
        time = parse_method("2000-01-01 12:13:14", :datetime)
        Time.zone.utc_offset.should == 10.hours
      end
    end

    it "should return nil for invalid date string" do
      parse_method("2000-02-30", :date).should be_nil      
    end
        
    def parse_method(*args)
      ActiveRecord::Base.parse_date_time(*args)
    end
  end

  describe "make_time" do

    if RAILS_VER >= '2.1'

      it "should create time using current timezone" do
        Time.zone = 'Melbourne'
        time = ActiveRecord::Base.send(:make_time, [2000,1,1,12,0,0])
        time.zone.should == "EST"
      end

    else

      it "should create time using default timezone" do
        time = ActiveRecord::Base.send(:make_time, [2000,1,1,12,0,0])
        time.zone.should == "UTC"
      end

    end

  end

end
