require 'spec_helper'

describe ValidatesTimeliness::Validator do
  include ModelHelpers
  NIL = [nil]

  before do
    Timecop.freeze(Time.local_time(2010, 1, 1, 0, 0, 0))
  end

  it 'should return validator kind as :timeliness' do
    ValidatesTimeliness::Validator.kind.should == :timeliness 
  end

  describe "Model.validates :timeliness option" do
    it 'should use plugin validator class' do
      Person.validates :birth_date, :timeliness => {:is_at => Date.new(2010,1,1), :type => :date}
      Person.validators.should have(1).kind_of(TimelinessValidator)
      invalid!(:birth_date, Date.new(2010,1,2))
      valid!(:birth_date, Date.new(2010,1,1))
    end

    it 'should use default to :datetime type' do
      Person.validates :birth_datetime, :timeliness => {:is_at => Time.mktime(2010,1,1)}
      Person.validators.first.type.should == :datetime
    end
  end

  it 'should not be valid for value which not valid date or time value' do
    Person.validates_date :birth_date
    invalid!(:birth_date, "Not a date", 'is not a valid date')
  end

  it 'should not be valid attribute is type cast to nil but raw value is non-nil invalid value' do
    Person.validates_date :birth_date, :allow_nil => true
    record = Person.new
    record.stub!(:birth_date).and_return(nil)
    record.stub!(:_timeliness_raw_value_for).and_return("Not a date")
    record.should_not be_valid
    record.errors[:birth_date].first.should == 'is not a valid date'
  end

  describe ":allow_nil option" do
    it 'should not allow nil by default' do
      Person.validates_date :birth_date
      invalid!(:birth_date, NIL, 'is not a valid date')
      valid!(:birth_date, Date.today)
    end

    it 'should allow nil when true' do
      Person.validates_date :birth_date, :allow_nil => true
      valid!(:birth_date, NIL)
    end
  end

  describe ":allow_blank option" do
    it 'should not allow blank by default' do
      Person.validates_date :birth_date
      invalid!(:birth_date, '', 'is not a valid date')
      valid!(:birth_date, Date.today)
    end

    it 'should allow blank when true' do
      Person.validates_date :birth_date, :allow_blank => true
      valid!(:birth_date, '')
    end
  end

  describe ":between option" do
    describe "array value" do
      it 'should be split option into :on_or_after and :on_or_before values' do
        on_or_after, on_or_before = Date.new(2010,1,1), Date.new(2010,1,2)
        Person.validates_time :birth_date, :between => [on_or_after, on_or_before]
        Person.validators.first.options[:on_or_after].should == on_or_after
        Person.validators.first.options[:on_or_before].should == on_or_before
      end
    end

    describe "range value" do
      it 'should be split option into :on_or_after and :on_or_before values' do
        on_or_after, on_or_before = Date.new(2010,1,1), Date.new(2010,1,2)
        Person.validates_time :birth_date, :between => on_or_after..on_or_before
        Person.validators.first.options[:on_or_after].should == on_or_after
        Person.validators.first.options[:on_or_before].should == on_or_before
      end
    end
  end

  describe "restriction value errors" do
    let(:person) { Person.new(:birth_date => Date.today) }

    before do
      Person.validates_time :birth_date, :is_at => lambda { raise }
    end

    it "should be added when ignore_restriction_errors is false" do
      ValidatesTimeliness.ignore_restriction_errors = false
      person.valid?
      person.errors[:birth_date].first.should match("Error occurred validating birth_date for :is_at restriction")
    end

    it "should not be added when ignore_restriction_errors is true" do
      ValidatesTimeliness.ignore_restriction_errors = true
      person.valid?
      person.errors[:birth_date].should be_empty
    end

    after :all do
      ValidatesTimeliness.ignore_restriction_errors = false
    end
  end

  describe "#format_error_value" do
    let(:validator) { ValidatesTimeliness::Validator.new(:attributes => [:birth_date], :type => :date) }

    describe "default" do
      it 'should format date error value as yyyy-mm-dd' do
        validator = ValidatesTimeliness::Validator.new(:attributes => [:birth_date], :type => :date)
        validator.format_error_value(Date.new(2010,1,1)).should == '2010-01-01'
      end

      it 'should format time error value as hh:nn:ss' do
        validator = ValidatesTimeliness::Validator.new(:attributes => [:birth_time], :type => :time)
        validator.format_error_value(Time.mktime(2010,1,1,12,34,56)).should == '12:34:56'
      end

      it 'should format datetime error value as yyyy-mm-dd hh:nn:ss' do
        validator = ValidatesTimeliness::Validator.new(:attributes => [:birth_datetime], :type => :datetime)
        validator.format_error_value(Time.mktime(2010,1,1,12,34,56)).should == '2010-01-01 12:34:56'
      end
    end
  end

  context "custom error message" do
  
    it 'should be used for failing restriction' do
      Person.validates_date :birth_date, :before => Time.now, :before_message => 'custom before message'
      invalid!(:birth_date, Time.now, 'custom before message')
    end

  end
end
