RSpec.describe ValidatesTimeliness::Validator do
  before do
    Timecop.freeze(Time.local(2010, 1, 1, 0, 0, 0))
  end

  describe "Model.validates with :timeliness option" do
    it 'should use plugin validator class' do
      Person.validates :birth_date, :timeliness => {:is_at => Date.new(2010,1,1), :type => :date}
      expect(Person.validators.select { |v| v.is_a?(ActiveModel::Validations::TimelinessValidator) }.size).to eq(1)
      invalid!(:birth_date, Date.new(2010,1,2))
      valid!(:birth_date, Date.new(2010,1,1))
    end

    it 'should use default to :datetime type' do
      Person.validates :birth_datetime, :timeliness => {:is_at => Time.mktime(2010,1,1)}
      expect(Person.validators.first.type).to eq(:datetime)
    end

    it 'should add attribute to timeliness attributes set' do
      expect(PersonWithShim.timeliness_validated_attributes).not_to include(:birth_time)

      PersonWithShim.validates :birth_time, :timeliness => {:is_at => "12:30"}

      expect(PersonWithShim.timeliness_validated_attributes).to include(:birth_time)
    end
  end

  it 'should not be valid for value which not valid date or time value' do
    Person.validates_date :birth_date
    invalid!(:birth_date, "Not a date", 'is not a valid date')
  end

  it 'should not be valid attribute is type cast to nil but raw value is non-nil invalid value' do
    Person.validates_date :birth_date, :allow_nil => true
    record = Person.new
    allow(record).to receive(:birth_date).and_return(nil)
    allow(record).to receive(:read_timeliness_attribute_before_type_cast).and_return("Not a date")
    expect(record).not_to be_valid
    expect(record.errors[:birth_date].first).to eq('is not a valid date')
  end

  describe ":allow_nil option" do
    it 'should not allow nil by default' do
      Person.validates_date :birth_date
      invalid!(:birth_date, [nil], 'is not a valid date')
      valid!(:birth_date, Date.today)
    end

    it 'should allow nil when true' do
      Person.validates_date :birth_date, :allow_nil => true
      valid!(:birth_date, [nil])
    end

    context "with raw value cache" do
      it "should not be valid with an invalid format" do
        PersonWithShim.validates_date :birth_date, :allow_nil => true

        p = PersonWithShim.new
        p.birth_date = 'bogus'

        expect(p).not_to be_valid
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

        expect(p).not_to be_valid
      end
    end
  end

  describe ':message options' do
    it 'should allow message option too' do
      Person.validates_date :birth_date, on_or_after: :today, message: 'cannot be in past'
      invalid!(:birth_date, Date.today - 5.days, 'cannot be in past')
      valid!(:birth_date, Date.today)
    end

    it 'should first allow the defined message' do
      Person.validates_date :birth_date, on_or_after: :today, on_or_after_message: 'cannot be in past', message: 'dummy message'
      invalid!(:birth_date, Date.today - 5.days, 'cannot be in past')
      valid!(:birth_date, Date.today)
    end
  end

  describe ":between option" do
    describe "array value" do
      it 'should be split option into :on_or_after and :on_or_before values' do
        on_or_after, on_or_before = Date.new(2010,1,1), Date.new(2010,1,2)
        Person.validates_date :birth_date, :between => [on_or_after, on_or_before]
        expect(Person.validators.first.options[:on_or_after]).to eq(on_or_after)
        expect(Person.validators.first.options[:on_or_before]).to eq(on_or_before)
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
        expect(Person.validators.first.options[:on_or_after]).to eq(on_or_after)
        expect(Person.validators.first.options[:on_or_before]).to eq(on_or_before)
        invalid!(:birth_date, on_or_after - 1, "must be on or after 2010-01-01")
        invalid!(:birth_date, on_or_before + 1, "must be on or before 2010-01-02")
        valid!(:birth_date, on_or_after)
        valid!(:birth_date, on_or_before)
      end
    end

    describe "range with excluded end value" do
      it 'should be split option into :on_or_after and :before values' do
        on_or_after, before = Date.new(2010,1,1), Date.new(2010,1,3)
        Person.validates_date :birth_date, :between => on_or_after...before
        expect(Person.validators.first.options[:on_or_after]).to eq(on_or_after)
        expect(Person.validators.first.options[:before]).to eq(before)
        invalid!(:birth_date, on_or_after - 1, "must be on or after 2010-01-01")
        invalid!(:birth_date, before, "must be before 2010-01-03")
        valid!(:birth_date, on_or_after)
        valid!(:birth_date, before - 1)
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
      expect(person.errors[:birth_date]).to be_empty
    end

    it "should not be valid when value does not match format" do
      person.birth_date = '1913-12-11'
      person.valid?
      expect(person.errors[:birth_date]).to include('is not a valid date')
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
        expect(person.errors[:birth_date].first).to match("Error occurred validating birth_date")
      end
    end

    it "should not be added when ignore_restriction_errors is true" do
      with_config(:ignore_restriction_errors, true) do
        person.valid?
        expect(person.errors[:birth_date]).to be_empty
      end
    end

    it 'should exit on first error' do
      with_config(:ignore_restriction_errors, false) do
        person.valid?
        expect(person.errors[:birth_date].size).to eq(1)
      end
    end
  end

  describe "#format_error_value" do
    describe "default" do
      it 'should format date error value as yyyy-mm-dd' do
        validator = ValidatesTimeliness::Validator.new(:attributes => [:birth_date], :type => :date)
        expect(validator.format_error_value(Date.new(2010,1,1))).to eq('2010-01-01')
      end

      it 'should format time error value as hh:nn:ss' do
        validator = ValidatesTimeliness::Validator.new(:attributes => [:birth_time], :type => :time)
        expect(validator.format_error_value(Time.mktime(2010,1,1,12,34,56))).to eq('12:34:56')
      end

      it 'should format datetime error value as yyyy-mm-dd hh:nn:ss' do
        validator = ValidatesTimeliness::Validator.new(:attributes => [:birth_datetime], :type => :datetime)
        expect(validator.format_error_value(Time.mktime(2010,1,1,12,34,56))).to eq('2010-01-01 12:34:56')
      end
    end

    describe "with missing translation" do
      before :all do
        I18n.locale = :es
      end

      it 'should use the default format for the type' do
        validator = ValidatesTimeliness::Validator.new(:attributes => [:birth_date], :type => :date)
        expect(validator.format_error_value(Date.new(2010,1,1))).to eq('2010-01-01')
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
