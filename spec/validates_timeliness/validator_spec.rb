require 'spec_helper'

describe ValidatesTimeliness::Validator do
  NIL = [nil]

  before do
    Timecop.freeze(Time.local_time(2010, 1, 1, 0, 0, 0))
  end

  describe "Model.validates with :timeliness option" do
    it 'should use plugin validator class' do
      Person.validates :birth_date, :timeliness => {:is_at => Date.new(2010,1,1), :type => :date}
      Person.validators.should have(1).kind_of(ActiveModel::Validations::TimelinessValidator)
      invalid!(:birth_date, Date.new(2010,1,2))
      valid!(:birth_date, Date.new(2010,1,1))
    end

    it 'should use default to :datetime type' do
      Person.validates :birth_datetime, :timeliness => {:is_at => Time.mktime(2010,1,1)}
      Person.validators.first.type.should == :datetime
    end

    it 'should add attribute to timeliness attributes set' do
      PersonWithShim.timeliness_validated_attributes.should_not include(:birth_time)

      PersonWithShim.validates :birth_time, :timeliness => {:is_at => "12:30"}

      PersonWithShim.timeliness_validated_attributes.should include(:birth_time)
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

    context "with raw value cache" do
      it "should not be valid with an invalid format" do
        PersonWithShim.validates_date :birth_date, :allow_nil => true

        p = PersonWithShim.new
        p.birth_date = 'bogus'

        p.should_not be_valid
      end
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

    context "with raw value cache" do
      it "should not be valid with an invalid format" do
        PersonWithShim.validates_date :birth_date, :allow_blank => true

        p = PersonWithShim.new
        p.birth_date = 'bogus'

        p.should_not be_valid
      end
    end
  end

  describe ":between option" do
    describe "array value" do
      it 'should be split option into :on_or_after and :on_or_before values' do
        on_or_after, on_or_before = Date.new(2010,1,1), Date.new(2010,1,2)
        Person.validates_date :birth_date, :between => [on_or_after, on_or_before]
        Person.validators.first.options[:on_or_after].should == on_or_after
        Person.validators.first.options[:on_or_before].should == on_or_before
        invalid!(:birth_date, on_or_after - 1, "must be on or after 2010-01-01")
        invalid!(:birth_date, on_or_before + 1, "must be on or before 2010-01-02")
        valid!(:birth_date, on_or_after)
        valid!(:birth_date, on_or_before)
      end
    end

    describe "range value" do
      it 'should be split option into :on_or_after and :on_or_before values' do
        on_or_after, on_or_before = Date.new(2010,1,1), Date.new(2010,1,2)
        Person.validates_date :birth_date, :between => on_or_after..on_or_before
        Person.validators.first.options[:on_or_after].should == on_or_after
        Person.validators.first.options[:on_or_before].should == on_or_before
        invalid!(:birth_date, on_or_after - 1, "must be on or after 2010-01-01")
        invalid!(:birth_date, on_or_before + 1, "must be on or before 2010-01-02")
        valid!(:birth_date, on_or_after)
        valid!(:birth_date, on_or_before)
      end
    end
  end

  describe ":ignore_usec option" do
    it "should not be valid when usec values don't match and option is false" do
      Person.validates_datetime :birth_datetime, :on_or_before => Time.utc(2010,1,2,3,4,5), :ignore_usec => false
      invalid!(:birth_datetime, Time.utc(2010,1,2,3,4,5,10000))
    end

    it "should be valid when usec values dont't match and option is true" do
      Person.validates_datetime :birth_datetime, :on_or_before => Time.utc(2010,1,2,3,4,5), :ignore_usec => true
      valid!(:birth_datetime, Time.utc(2010,1,2,3,4,5,10000))
    end
  end

  describe ":format option" do
    class PersonWithFormatOption
      include TestModel
      include TestModelShim
      attribute :birth_date, :date
      attribute :birth_time, :time
      attribute :birth_datetime, :datetime
      validates_date :birth_date, :format => 'dd-mm-yyyy'
    end

    let(:person) { PersonWithFormatOption.new }

    with_config(:use_plugin_parser, true)

    it "should be valid when value matches format" do
      person.birth_date = '11-12-1913'
      person.valid?
      person.errors[:birth_date].should be_empty
    end

    it "should not be valid when value does not match format" do
      person.birth_date = '1913-12-11'
      person.valid?
      person.errors[:birth_date].should include('is not a valid date')
    end
  end

  describe "restriction value errors" do
    let(:person) { Person.new(:birth_date => Date.today) }

    before do
      Person.validates_time :birth_date, :is_at => lambda { raise }, :before => lambda { raise }
    end

    it "should be added when ignore_restriction_errors is false" do
      with_config(:ignore_restriction_errors, false) do
        person.valid?
        person.errors[:birth_date].first.should match("Error occurred validating birth_date")
      end
    end

    it "should not be added when ignore_restriction_errors is true" do
      with_config(:ignore_restriction_errors, true) do
        person.valid?
        person.errors[:birth_date].should be_empty
      end
    end

    it 'should exit on first error' do
      with_config(:ignore_restriction_errors, false) do
        person.valid?
        person.errors[:birth_date].should have(1).items
      end
    end
  end

  describe "#format_error_value" do
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

    describe "with missing translation" do
      before :all do
        I18n.locale = :es
      end

      it 'should use the default format for the type' do
        validator = ValidatesTimeliness::Validator.new(:attributes => [:birth_date], :type => :date)
        validator.format_error_value(Date.new(2010,1,1)).should == '2010-01-01'
      end

      after :all do
        I18n.locale = :en
      end
    end
  end

  context "custom error message" do
    it 'should be used for invalid type' do
      Person.validates_date :birth_date, :invalid_date_message => 'custom invalid message'
      invalid!(:birth_date, 'asdf', 'custom invalid message')
    end
  
    it 'should be used for invalid restriction' do
      Person.validates_date :birth_date, :before => Time.now, :before_message => 'custom before message'
      invalid!(:birth_date, Time.now, 'custom before message')
    end
  end
end
