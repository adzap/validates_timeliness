require 'spec_helper'

describe ValidatesTimeliness::HelperMethods do
  it 'should define class validation methods' do
    Person.should respond_to(:validates_date)
    Person.should respond_to(:validates_time)
    Person.should respond_to(:validates_datetime)
  end

  it 'should define instance validation methods' do
    Person.instance_methods.should include('validates_date')
    Person.instance_methods.should include('validates_time')
    Person.instance_methods.should include('validates_datetime')
  end

  it 'should validate instance when validation method called' do
    r = Person.new
    r.validates_date :birth_date
    r.errors[:birth_date].should_not be_empty
  end

  describe ".timeliness_validated_attributes" do
    it 'should return attributes validated with plugin validator' do
      Person.timeliness_validated_attributes = []
      Person.validates_date :birth_date
      Person.validates_time :birth_time
      Person.validates_datetime :birth_datetime

      Person.timeliness_validated_attributes.should == [ :birth_date, :birth_time, :birth_datetime ]
    end
  end

end
