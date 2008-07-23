require File.dirname(__FILE__) + '/spec_helper'

describe ValidatesTimeliness::Validations do
  before :all do
    # freezes time using time_travel plugin
    Time.now = Time.utc(2000, 1, 1, 0, 0, 0)
  end
  
  after :all do
    Time.now = nil
  end
  
  describe "timeliness_date_time_parse" do
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
   
  describe "with no restrictions" do
    before :all do
      class BasicValidation < Person
        validates_timeliness_of :birth_date_and_time, :allow_blank => true, :type => :datetime
        validates_timeliness_of :birth_date, :allow_blank => true, :type => :date
        validates_timeliness_of :birth_time, :allow_blank => true, :type => :time
      end
    end

    before :each do
      @person = BasicValidation.new
    end

    it "should have error for invalid date component for datetime column" do
      @person.birth_date_and_time = "2000-01-32 01:02:03"
      @person.should_not be_valid
      @person.errors.on(:birth_date_and_time).should == "is not a valid datetime"
    end

    it "should have error for invalid time component for datetime column" do
      @person.birth_date_and_time = "2000-01-01 25:02:03"
      @person.should_not be_valid 
      @person.errors.on(:birth_date_and_time).should == "is not a valid datetime"
    end

    it "should have error for invalid date value for date column" do
      @person.birth_date = "2000-01-32"
      @person.should_not be_valid
      @person.errors.on(:birth_date).should == "is not a valid date"
    end

    it "should have error for invalid time value for time column" do
      @person.birth_time = "25:00"
      @person.should_not be_valid
      @person.errors.on(:birth_time).should == "is not a valid time"
    end

    it "should be valid with valid values" do
      @person.birth_date_and_time = "2000-01-01 12:12:12"
      @person.birth_date = "2000-01-31"
      @person.should be_valid
    end
    
    it "should be valid with values before out of Time range" do
      @person.birth_date_and_time = "1890-01-01 12:12:12"
      @person.birth_date = "1890-01-31"
      @person.birth_time = "23:59:59"
      @person.should be_valid
    end
    
    it "should be valid with nil values when allow_blank si true" do
      @person.birth_date_and_time = nil
      @person.birth_date = nil
      @person.birth_time = nil      
      @person.should be_valid
    end
  end
  
  describe "for datetime type" do
    
    describe "with before and after restrictions" do
      before :all do
        class DateTimeBeforeAfter < Person
          validates_timeliness_of :birth_date_and_time, :type => :datetime,
            :before => lambda { Time.now }, :after => lambda { 1.day.ago}
        end
      end

      before :each do
        @person = DateTimeBeforeAfter.new
      end
      
      it "should have error when past :before restriction" do
        @person.birth_date_and_time = 1.minute.from_now
        @person.should_not be_valid
        @person.errors.on(:birth_date_and_time).should match(/must be before/)
      end

      it "should have error when before :after restriction" do
        @person.birth_date_and_time = 2.days.ago
        @person.should_not be_valid
        @person.errors.on(:birth_date_and_time).should match(/must be after/)
      end
      
      it "should have error when on boundary of :before restriction" do
        @person.birth_date_and_time = Time.now
        @person.should_not be_valid
        @person.errors.on(:birth_date_and_time).should match(/must be before/)
      end

      it "should have error when on boundary of :after restriction" do
        @person.birth_date_and_time = 1.day.ago
        @person.should_not be_valid
        @person.errors.on(:birth_date_and_time).should match(/must be after/)
      end
    end

    describe "with on_or_before and on_or_after restrictions" do
      before :all do
        class DateTimeOnOrBeforeAndAfter < Person
          validates_timeliness_of :birth_date_and_time, :type => :datetime,
            :on_or_before => lambda { Time.now.at_midnight },
            :on_or_after => lambda { 1.day.ago }
        end
      end
      
      before do  
        @person = DateTimeOnOrBeforeAndAfter.new
      end
        
      it "should have error when past :on_or_before restriction" do
        @person.birth_date_and_time = Time.now.at_midnight + 1
        @person.should_not be_valid
        @person.errors.on(:birth_date_and_time).should match(/must be on or before/)
      end

      it "should have error when before :on_or_after restriction" do
        @person.birth_date_and_time = 1.days.ago - 1
        @person.should_not be_valid
        @person.errors.on(:birth_date_and_time).should match(/must be on or after/)
      end
      
      it "should be valid when value equal to :on_or_before restriction" do
        @person.birth_date_and_time = Time.now.at_midnight
        @person.should be_valid
      end

      it "should be valid when value equal to :on_or_after restriction" do
        @person.birth_date_and_time = 1.day.ago
        @person.should be_valid        
      end 
    end

  end
  
  describe "for date type" do
    
    describe "with before and after restrictions" do
      before :all do
        class DateBeforeAfter < Person
          validates_timeliness_of :birth_date, :type => :date,
            :before => 1.day.from_now, 
            :after => 1.day.ago
        end        
      end

      before :each do
        @person = DateBeforeAfter.new
      end
      
      it "should have error when past :before restriction" do
        @person.birth_date = 2.days.from_now
        @person.should_not be_valid
        @person.errors.on(:birth_date).should match(/must be before/)
      end

      it "should have error when before :after restriction" do
        @person.birth_date = 2.days.ago
        @person.should_not be_valid
        @person.errors.on(:birth_date).should match(/must be after/)
      end
    end

    describe "with on_or_before and on_or_after restrictions" do
      before :all do
        class DateOnOrBeforeAndAfter < Person
          validates_timeliness_of :birth_date, :type => :date, 
            :on_or_before => 1.day.from_now,
            :on_or_after => 1.day.ago
        end
      end
      
      before :each do
        @person = DateOnOrBeforeAndAfter.new
      end
        
      it "should have error when past :on_or_before restriction" do
        @person.birth_date = 2.days.from_now
        @person.should_not be_valid
        @person.errors.on(:birth_date).should match(/must be on or before/)
      end

      it "should have error when before :on_or_after restriction" do
        @person.birth_date = 2.days.ago
        @person.should_not be_valid
        @person.errors.on(:birth_date).should match(/must be on or after/)
      end
      
      it "should be valid when value equal to :on_or_before restriction" do
        @person.birth_date = 1.day.from_now
        @person.should be_valid
      end

      it "should be valid when value equal to :on_or_after restriction" do
        @person.birth_date = 1.day.ago
        @person.should be_valid        
      end      
    end 
  end
  
  describe "for time type" do
  
    describe "with before and after restrictions" do
      before :all do
        class TimeBeforeAfter < Person
          validates_timeliness_of :birth_time, :type => :time,
            :before => "23:00", 
            :after => "06:00"
        end        
      end

      before :each do
        @person = TimeBeforeAfter.new
      end
      
      it "should have error when on boundary of :before restriction" do
        @person.birth_time = "23:00"
        @person.should_not be_valid
        @person.errors.on(:birth_time).should match(/must be before/)
      end

      it "should have error when on boundary of :after restriction" do
        @person.birth_time = "06:00am"
        @person.should_not be_valid
        @person.errors.on(:birth_time).should match(/must be after/)
      end
      
      it "should have error when past :before restriction" do
        @person.birth_time = "23:01"
        @person.should_not be_valid
        @person.errors.on(:birth_time).should match(/must be before/)
      end

      it "should have error when before :after restriction" do
        @person.birth_time = "05:59"
        @person.should_not be_valid
        @person.errors.on(:birth_time).should match(/must be after/)
      end
      
      it "should not have error when before :before restriction" do
        @person.birth_time = "22:59"
        @person.should be_valid
      end

      it "should have error when before :after restriction" do
        @person.birth_time = "06:01"
        @person.should be_valid
      end
    end

    describe "with on_or_before and on_or_after restrictions" do
      before :all do
        class TimeOnOrBeforeAndAfter < Person
          validates_timeliness_of :birth_time, :type => :time,
            :on_or_before => "23:00",
            :on_or_after => "06:00"
        end
      end
      
      before :each do
        @person = TimeOnOrBeforeAndAfter.new
      end
        
      it "should have error when past :on_or_before restriction" do
        @person.birth_time = "23:01"
        @person.should_not be_valid
        @person.errors.on(:birth_time).should match(/must be on or before/)
      end

      it "should have error when before :on_or_after restriction" do
        @person.birth_time = "05:59"
        @person.should_not be_valid
        @person.errors.on(:birth_time).should match(/must be on or after/)
      end
      
      it "should be valid when on boundary of :on_or_before restriction" do
        @person.birth_time = "23:00"
        @person.should be_valid
      end

      it "should be valid when on boundary of :on_or_after restriction" do
        @person.birth_time = "06:00"
        @person.should be_valid        
      end      
    end 
  end
  
  describe "with mixed value and restriction types" do
    before :all do
      
      class MixedBeforeAndAfter < Person
        validates_timeliness_of :birth_date_and_time, 
                                  :before => Date.new(2000,1,2), 
                                  :after => lambda { "2000-01-01" }
        validates_timeliness_of :birth_date, :type => :date, 
                                  :on_or_before => lambda { "2000-01-01" }, 
                                  :on_or_after => :birth_date_and_time
      end
    end
    
    before :each do
      @person = MixedBeforeAndAfter.new
    end
    
    it "should correctly validate time attribute with Date restriction" do
      @person.birth_date_and_time = "2000-01-03 00:00:00"
      @person.should_not be_valid
      @person.errors.on(:birth_date_and_time).should match(/must be before/)
    end
    
    it "should correctly validate with proc restriction" do
      @person.birth_date_and_time = "2000-01-01 00:00:00"
      @person.should_not be_valid
      @person.errors.on(:birth_date_and_time).should match(/must be after/)
    end

    it "should correctly validate date attribute with DateTime restriction" do
      @person.birth_date = "2000-01-03"
      @person.birth_date_and_time = "1890-01-01 00:00:00"
      @person.should_not be_valid
      @person.errors.on(:birth_date).should match(/must be on or before/)
    end

    it "should correctly validate date attribute with symbol restriction" do
      @person.birth_date = "2000-01-01"
      @person.birth_date_and_time = "2000-01-02 12:00:00"
      @person.should_not be_valid
      @person.errors.on(:birth_date).should match(/must be on or after/)
    end

  end
  
  describe "ignoring restriction errors" do
    before :all do
      class BadRestriction < Person        
        validates_date :birth_date, :before => Proc.new { raise }
        self.ignore_datetime_restriction_errors = true
      end
    end
    
    before :each do
      @person = BadRestriction.new
    end
    
    it "should have no errors when restriction is invalid" do
      @person.birth_date = '2000-01-01'
      @person.should be_valid
    end
  end
end
