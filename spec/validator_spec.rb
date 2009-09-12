require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe ValidatesTimeliness::Validator do
  attr_accessor :person, :validator

  before :all do
    # freezes time using time_travel plugin
    Time.now = Time.utc(2000, 1, 1, 0, 0, 0)
  end

  after :all do
    Time.now = nil
  end

  before :each do
    @person = Person.new
  end

  describe "option keys validation" do
    before do
      keys = ValidatesTimeliness::Validator::VALID_OPTIONS - [:invalid_date_message, :invalid_time_message, :with_date, :with_time]
      @valid_options = keys.inject({}) {|hash, opt| hash[opt] = nil; hash }
    end

    it "should raise error if invalid option key passed" do
      @valid_options.update(:invalid_key => 'will not open lock')
      lambda { Person.validates_datetime(@valid_options) }.should raise_error(ArgumentError)
    end

    it "should not raise error if option keys are valid" do
      lambda { Person.validates_datetime(@valid_options) }.should_not raise_error(ArgumentError)
    end
  end

  describe "evaluate_option_value" do
    it "should return Time object when restriction is Time object" do
      evaluate_option_value(Time.now, :datetime).should be_kind_of(Time)
    end

    it "should return Time object when restriction is string" do
      evaluate_option_value("2007-01-01 12:00", :datetime).should be_kind_of(Time)
    end

    it "should return Time object when restriction is method and method returns Time object" do
      person.stub!(:datetime_attr).and_return(Time.now)
      evaluate_option_value(:datetime_attr, :datetime).should be_kind_of(Time)
    end

    it "should return Time object when restriction is method and method returns string" do
      person.stub!(:datetime_attr).and_return("2007-01-01 12:00")
      evaluate_option_value(:datetime_attr, :datetime).should be_kind_of(Time)
    end

    it "should return Time object when restriction is proc which returns Time object" do
      evaluate_option_value(lambda { Time.now }, :datetime).should be_kind_of(Time)
    end

    it "should return Time object when restriction is proc which returns string" do
      evaluate_option_value(lambda {"2007-01-01 12:00"}, :datetime).should be_kind_of(Time)
    end

    it "should return array of Time objects when restriction is array of Time objects" do
      time1, time2 = Time.now, 1.day.ago
      evaluate_option_value([time1, time2], :datetime).should == [time2, time1]
    end

    it "should return array of Time objects when restriction is array of strings" do
      time1, time2 = "2000-01-02", "2000-01-01"
      evaluate_option_value([time1, time2], :datetime).should == [parse(time2, :datetime), parse(time1, :datetime)]
    end

    it "should return array of Time objects when restriction is Range of Time objects" do
      time1, time2 = Time.now, 1.day.ago
      evaluate_option_value(time1..time2, :datetime).should == [time2, time1]
    end

    it "should return array of Time objects when restriction is Range of time strings" do
      time1, time2 = "2000-01-02", "2000-01-01"
      evaluate_option_value(time1..time2, :datetime).should == [parse(time2, :datetime), parse(time1, :datetime)]
    end
    def evaluate_option_value(restriction, type)
      configure_validator(:type => type)
      validator.class.send(:evaluate_option_value, restriction, type, person)
    end
  end

  describe "instance with defaults" do

    describe "for datetime type" do
      before do
        configure_validator(:type => :datetime)
      end

      it "should have invalid error when date component is invalid" do
        validate_with(:birth_date_and_time, "2000-01-32 01:02:03")
        should_have_error(:birth_date_and_time, :invalid_datetime)
      end

      it "should have invalid error when time component is invalid" do
        validate_with(:birth_date_and_time, "2000-01-01 25:02:03")
        should_have_error(:birth_date_and_time, :invalid_datetime)
      end

      it "should have blank error when value is nil" do
        validate_with(:birth_date_and_time, nil)
        should_have_error(:birth_date_and_time, :blank)
      end

      it "should have no errors when value is valid" do
        validate_with(:birth_date_and_time, "2000-01-01 12:00:00")
        should_have_no_error(:birth_date_and_time, :invalid_datetime)
      end
    end

    describe "for date type" do
      before do
        configure_validator(:type => :date)
      end

      it "should have invalid error when value is invalid" do
        validate_with(:birth_date, "2000-01-32")
        should_have_error(:birth_date, :invalid_date)
      end

      it "should have blank error when value is nil" do
        validate_with(:birth_date, nil)
        should_have_error(:birth_date, :blank)
      end

      it "should have no error when value is valid" do
        validate_with(:birth_date, "2000-01-31")
        should_have_no_error(:birth_date, :invalid_date)
      end
    end

    describe "for time type" do
      before do
        configure_validator(:type => :time)
      end

      it "should have invalid error when value is invalid" do
        validate_with(:birth_time, "25:00")
        should_have_error(:birth_time, :invalid_time)
      end

      it "should have blank error when value is nil" do
        validate_with(:birth_time, nil)
        should_have_error(:birth_time, :blank)
      end

      it "should have no errors when value is valid" do
        validate_with(:birth_date_and_time, "12:00")
        should_have_no_error(:birth_time, :invalid_time)
      end
    end

  end

  describe "instance with before and after restrictions" do

    describe "for datetime type" do
      before :each do
        configure_validator(:before => lambda { Time.now }, :after => lambda { 1.day.ago})
      end

      it "should have before error when value is past :before restriction" do
        validate_with(:birth_date_and_time, 1.minute.from_now)
        should_have_error(:birth_date_and_time, :before)
      end

      it "should have before error when value is on boundary of :before restriction" do
        validate_with(:birth_date_and_time, Time.now)
        should_have_error(:birth_date_and_time, :before)
      end

      it "should have after error when value is before :after restriction" do
        validate_with(:birth_date_and_time, 2.days.ago)
        should_have_error(:birth_date_and_time, :after)
      end

      it "should have after error when value is on boundary of :after restriction" do
        validate_with(:birth_date_and_time, 1.day.ago)
        should_have_error(:birth_date_and_time, :after)
      end
    end

    describe "for date type" do
      before :each do
        configure_validator(:before => 1.day.from_now, :after => 1.day.ago, :type => :date)
      end

      it "should have error when value is past :before restriction" do
        validate_with(:birth_date, 2.days.from_now)
        should_have_error(:birth_date, :before)
      end

      it "should have error when value is before :after restriction" do
        validate_with(:birth_date, 2.days.ago)
        should_have_error(:birth_date, :after)
      end

      it "should have no error when value is before :before restriction" do
        validate_with(:birth_date, Time.now)
        should_have_no_error(:birth_date, :before)
      end

      it "should have no error when value is after :after restriction" do
        validate_with(:birth_date, Time.now)
        should_have_no_error(:birth_date, :after)
      end
    end

    describe "for time type" do
      before :each do
        configure_validator(:before => "23:00", :after => "06:00", :type => :time)
      end

      it "should have error when value is on boundary of :before restriction" do
        validate_with(:birth_time, "23:00")
        should_have_error(:birth_time, :before)
      end

      it "should have error when value is on boundary of :after restriction" do
        validate_with(:birth_time, "06:00")
        should_have_error(:birth_time, :after)
      end

      it "should have error when value is past :before restriction" do
        validate_with(:birth_time, "23:01")
        should_have_error(:birth_time, :before)
      end

      it "should have error when value is before :after restriction" do
        validate_with(:birth_time, "05:59")
        should_have_error(:birth_time, :after)
      end

      it "should not have error when value is before :before restriction" do
        validate_with(:birth_time, "22:59")
        should_have_no_error(:birth_time, :before)
      end

      it "should have error when value is before :after restriction" do
        validate_with(:birth_time, "06:01")
        should_have_no_error(:birth_time, :before)
      end
    end
  end

  describe "instance with between restriction" do

    describe "for datetime type" do
      before do
        configure_validator(:between => [1.day.ago.at_midnight, 1.day.from_now.at_midnight])
      end

      it "should have error when value is before earlist :between restriction" do
        validate_with(:birth_date_and_time, 2.days.ago)
        should_have_error(:birth_date_and_time, :between)
      end

      it "should have error when value is after latest :between restriction" do
        validate_with(:birth_date_and_time, 2.days.from_now)
        should_have_error(:birth_date_and_time, :between)
      end

      it "should be valid when value is equal to earliest :between restriction" do
        validate_with(:birth_date_and_time, 1.day.ago.at_midnight)
        should_have_no_error(:birth_date_and_time, :between)
      end

      it "should be valid when value is equal to latest :between restriction" do
        validate_with(:birth_date_and_time, 1.day.from_now.at_midnight)
        should_have_no_error(:birth_date_and_time, :between)
      end

      it "should allow a range for between restriction" do
        configure_validator(:type => :datetime, :between => (1.day.ago.at_midnight)..(1.day.from_now.at_midnight))
        validate_with(:birth_date_and_time, 1.day.from_now.at_midnight)
        should_have_no_error(:birth_date_and_time, :between)
      end
    end

    describe "for date type" do
      before do
        configure_validator(:type => :date, :between => [1.day.ago.to_date, 1.day.from_now.to_date])
      end

      it "should have error when value is before earlist :between restriction" do
        validate_with(:birth_date, 2.days.ago.to_date)
        should_have_error(:birth_date, :between)
      end

      it "should have error when value is after latest :between restriction" do
        validate_with(:birth_date, 2.days.from_now.to_date)
        should_have_error(:birth_date, :between)
      end

      it "should be valid when value is equal to earliest :between restriction" do
        validate_with(:birth_date, 1.day.ago.to_date)
        should_have_no_error(:birth_date, :between)
      end

      it "should be valid when value is equal to latest :between restriction" do
        validate_with(:birth_date, 1.day.from_now.to_date)
        should_have_no_error(:birth_date, :between)
      end
      
      it "should allow a range for between restriction" do
        configure_validator(:type => :date, :between => (1.day.ago.to_date)..(1.day.from_now.to_date))
        validate_with(:birth_date, 1.day.from_now.to_date)
        should_have_no_error(:birth_date, :between)
      end
    end

    describe "for time type" do
      before do
        configure_validator(:type => :time, :between => ["09:00", "17:00"])
      end

      it "should have error when value is before earlist :between restriction" do
        validate_with(:birth_time, "08:59")
        should_have_error(:birth_time, :between)
      end

      it "should have error when value is after latest :between restriction" do
        validate_with(:birth_time, "17:01")
        should_have_error(:birth_time, :between)
      end

      it "should be valid when value is equal to earliest :between restriction" do
        validate_with(:birth_time, "09:00")
        should_have_no_error(:birth_time, :between)
      end

      it "should be valid when value is equal to latest :between restriction" do
        validate_with(:birth_time, "17:00")
        should_have_no_error(:birth_time, :between)
      end

      it "should allow a range for between restriction" do
        configure_validator(:type => :time, :between => "09:00".."17:00")
        validate_with(:birth_time, "17:00")
        should_have_no_error(:birth_time, :between)
      end
    end
  end

  describe "instance with :equal_to restriction" do

    describe "for datetime type" do
      before do
        configure_validator(:equal_to => Time.now)
      end

      it "should have error when value not equal to :equal_to restriction" do
        validate_with(:birth_date_and_time, Time.now + 1)
        should_have_error(:birth_date_and_time, :equal_to)
      end

      it "should be valid when value is equal to :equal_to restriction" do
        validate_with(:birth_date_and_time, Time.now)
        should_have_no_error(:birth_date_and_time, :equal_to)
      end
    end

    describe "for date type" do
      before do
        configure_validator(:type => :date, :equal_to => Date.today)
      end

      it "should have error when value is not equal to :equal_to restriction" do
        validate_with(:birth_date, Date.today + 1)
        should_have_error(:birth_date, :equal_to)
      end

      it "should be valid when value is equal to :equal_to restriction" do
        validate_with(:birth_date, Date.today)
        should_have_no_error(:birth_date, :equal_to)
      end
    end

    describe "for time type" do
      before do
        configure_validator(:type => :time, :equal_to => "09:00:00")
      end

      it "should have error when value is not equal to :equal_to restriction" do
        validate_with(:birth_time, "09:00:01")
        should_have_error(:birth_time, :equal_to)
      end

      it "should be valid when value is equal to :equal_to restriction" do
        validate_with(:birth_time, "09:00:00")
        should_have_no_error(:birth_time, :equal_to)
      end
    end
  end

  describe "instance with :ignore_usec option" do

    it "should ignore usec on time values when evaluated" do
      configure_validator(:equal_to => Time.utc(2000, 1, 1, 0, 0, 0, 0), :ignore_usec => true)
      validate_with(:birth_date_and_time, Time.utc(2000, 1, 1, 0, 0, 0, 500))
      should_have_no_error(:birth_date_and_time, :equal_to)
    end

  end

  describe "instance with :with_time option" do

    it "should validate date attribute as datetime combining value of :with_time against restrictions " do
      configure_validator(:type => :date, :with_time => '12:31', :on_or_before => Time.mktime(2000,1,1,12,30))
      validate_with(:birth_date, "2000-01-01")
      should_have_error(:birth_date, :on_or_before)
    end

    it "should skip restriction validation if :with_time value is nil" do
      configure_validator(:type => :date, :with_time => nil, :on_or_before => Time.mktime(2000,1,1,12,30))
      validate_with(:birth_date, "2000-01-01")
      should_have_no_error(:birth_date, :on_or_before)
    end

    it "should should ignore usec value on combined value if :ignore_usec option is true" do
      configure_validator(:type => :date, :with_time => Time.mktime(2000,1,1,12,30,0,500), :equal_to => Time.mktime(2000,1,1,12,30), :ignore_usec => true)
      validate_with(:birth_date, "2000-01-01")
      should_have_no_error(:birth_date, :equal_to)
    end
  end

  describe "instance with :with_date option" do

    it "should validate time attribute as datetime combining value of :with_date against restrictions " do
      configure_validator(:type => :time, :with_date => '2009-01-01', :on_or_before => Time.mktime(2000,1,1,12,30))
      validate_with(:birth_time, "12:30")
      should_have_error(:birth_time, :on_or_before)
    end

    it "should skip restriction validation if :with_date value is nil" do
      configure_validator(:type => :time, :with_date => nil, :on_or_before => Time.mktime(2000,1,1,12,30))
      validate_with(:birth_time, "12:30")
      should_have_no_error(:birth_time, :on_or_before)
    end

    it "should should ignore usec value on combined value if :ignore_usec option is true" do
      configure_validator(:type => :time, :with_date => Date.new(2000,1,1), :on_or_before => Time.mktime(2000,1,1,12,30), :ignore_usec => true)
      validate_with(:birth_time, Time.mktime(2000,1,1,12,30,0,50))
      should_have_no_error(:birth_time, :on_or_before)
    end
  end

  describe "instance with mixed value and restriction types" do

    it "should validate datetime attribute with Date restriction" do
      configure_validator(:type => :datetime, :on_or_before => Date.new(2000,1,1))
      validate_with(:birth_date_and_time, "2000-01-01 00:00:00")
      should_have_no_error(:birth_date_and_time, :on_or_before)
    end

    it "should validate date attribute with DateTime restriction value" do
      configure_validator(:type => :date, :on_or_before => DateTime.new(2000, 1, 1, 0,0,0))
      validate_with(:birth_date, "2000-01-01")
      should_have_no_error(:birth_date, :on_or_before)
    end

    it "should validate date attribute with Time restriction value" do
      configure_validator(:type => :date, :on_or_before => Time.utc(2000, 1, 1, 0,0,0))
      validate_with(:birth_date, "2000-01-01")
      should_have_no_error(:birth_date, :on_or_before)
    end

    it "should validate time attribute with DateTime restriction value" do
      configure_validator(:type => :time, :on_or_before => DateTime.new(2000, 1, 1, 12,0,0))
      validate_with(:birth_time, "12:00")
      should_have_no_error(:birth_time, :on_or_before)
    end

    it "should validate time attribute with Time restriction value" do
      configure_validator(:type => :time, :on_or_before => Time.utc(2000, 1, 1, 12,0,0))
      validate_with(:birth_time, "12:00")
      should_have_no_error(:birth_time, :on_or_before)
    end
  end

  describe "instance with format option" do
    it "should validate attribute when value matches format" do
      configure_validator(:type => :time, :format => 'hh:nn:ss')
      validate_with(:birth_time, "12:00:00")
      should_have_no_error(:birth_time, :invalid_time)
    end

    it "should not validate attribute when value does not match format" do
      configure_validator(:type => :time, :format => 'hh:nn:ss')
      validate_with(:birth_time, "12:00")
      should_have_error(:birth_time, :invalid_time)
    end
  end

  describe "custom_error_messages" do
    it "should return hash of custom error messages from configuration with _message truncated from keys" do
      configure_validator(:type => :date, :invalid_date_message => 'thats no date')
      validator.send(:custom_error_messages)[:invalid_date].should == 'thats no date'
    end

    it "should return empty hash if no custom error messages in configuration" do
      configure_validator(:type => :date)
      validator.send(:custom_error_messages).should be_empty
    end
  end

  describe "interpolation_values" do
    if defined?(I18n)
      it "should return hash of interpolation keys with restriction values" do
        before = '1900-01-01'
        configure_validator(:type => :date, :before => before)
        validator.send(:interpolation_values, :before, before.to_date).should == {:restriction => before}
      end
    else
      it "should return array of interpolation values" do
        before = '1900-01-01'
        configure_validator(:type => :date, :before => before)
        validator.send(:interpolation_values, :before, before.to_date).should == [before]
      end
    end
  end

  describe "restriction errors" do
    before :each do
      configure_validator(:type => :date, :before => lambda { raise })
    end

    it "should be added by default for invalid restriction" do
      ValidatesTimeliness::Validator.ignore_restriction_errors = false
      validate_with(:birth_date, Date.today)
      person.errors.on(:birth_date).should match(/restriction 'before' value was invalid/)
    end

    it "should not be added when ignore switch is true and restriction is invalid" do
      ValidatesTimeliness::Validator.ignore_restriction_errors = true
      person.should be_valid
    end

    after :all do
      ValidatesTimeliness::Validator.ignore_restriction_errors = false
    end
  end

  describe "restriction value error message" do

    describe "default formats" do

      it "should format datetime value of restriction" do
        configure_validator(:type => :datetime, :after => 1.day.from_now)
        validate_with(:birth_date_and_time, Time.now)
        person.errors.on(:birth_date_and_time).should match(/after \d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\Z/)
      end

      it "should format date value of restriction" do
        configure_validator(:type => :date, :after => 1.day.from_now)
        validate_with(:birth_date, Time.now)
        person.errors.on(:birth_date).should match(/after \d{4}-\d{2}-\d{2}\Z/)
      end

      it "should format time value of restriction" do
        configure_validator(:type => :time, :after => '12:00')
        validate_with(:birth_time, '11:59')
        person.errors.on(:birth_time).should match(/after \d{2}:\d{2}:\d{2}\Z/)
      end
    end

    describe "custom formats" do

      before :all do
        custom = {
          :time     => '%H:%M %p',
          :date     => '%d-%m-%Y',
          :datetime => '%d-%m-%Y %H:%M %p'
        }

        if defined?(I18n)
          I18n.backend.store_translations 'en', :validates_timeliness => { :error_value_formats => custom }
        else
          @@formats = ValidatesTimeliness::Validator.error_value_formats
          ValidatesTimeliness::Validator.error_value_formats = custom
        end
      end

      it "should format datetime value of restriction" do
        configure_validator(:type => :datetime, :after => 1.day.from_now)
        validate_with(:birth_date_and_time, Time.now)
        person.errors.on(:birth_date_and_time).should match(/after \d{2}-\d{2}-\d{4} \d{2}:\d{2} (AM|PM)\Z/)
      end

      it "should format date value of restriction" do
        configure_validator(:type => :date, :after => 1.day.from_now)
        validate_with(:birth_date, Time.now)
        person.errors.on(:birth_date).should match(/after \d{2}-\d{2}-\d{4}\Z/)
      end

      it "should format time value of restriction" do
        configure_validator(:type => :time, :after => '12:00')
        validate_with(:birth_time, '11:59')
        person.errors.on(:birth_time).should match(/after \d{2}:\d{2} (AM|PM)\Z/)
      end

      after :all do
        if defined?(I18n)
          I18n.reload!
        else
          ValidatesTimeliness::Validator.error_value_formats = @@formats
        end
      end
    end

  end

  def parse(*args)
    ValidatesTimeliness::Parser.parse(*args)
  end

  def configure_validator(options={})
    @validator = ValidatesTimeliness::Validator.new(options)
  end

  def validate_with(attr_name, value)
    person.send("#{attr_name}=", value)
    validator.call(person, attr_name, value)
  end

  def should_have_error(attr_name, error)
    message = error_messages[error]
    person.errors.on(attr_name).should match(/#{message}/)
  end

  def should_have_no_error(attr_name, error)
    message = error_messages[error]
    errors = person.errors.on(attr_name)
    if errors
      errors.should_not match(/#{message}/)
    else
      errors.should be_nil
    end
  end

  def error_messages
    return @error_messages if defined?(@error_messages)
    messages = validator.send(:error_messages)
    @error_messages = messages.inject({}) {|h, (k, v)| h[k] = v.sub(/ (\%s|\{\{\w*\}\}).*/, ''); h }
  end
end
