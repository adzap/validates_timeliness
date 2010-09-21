require 'spec_helper'

describe ValidatesTimeliness::HelperMethods do
  it 'should define class validation methods on extended classes' do
    ActiveRecord::Base.should respond_to(:validates_date)
    ActiveRecord::Base.should respond_to(:validates_time)
    ActiveRecord::Base.should respond_to(:validates_datetime)
  end

  it 'should define instance validation methods on extended classes' do
    ActiveRecord::Base.instance_methods.should include('validates_date')
    ActiveRecord::Base.instance_methods.should include('validates_time')
    ActiveRecord::Base.instance_methods.should include('validates_datetime')
  end

  it 'should validate instance when validation method called' do
    r = Person.new
    r.validates_date :birth_date
    r.errors[:birth_date].should_not be_empty
  end

  describe ".timeliness_validated_attributes" do
    it 'should return attributes validated with plugin validator' do
      Person.timeliness_validated_attributes = {}
      Person.validates_date :birth_date
      Person.validates_time :birth_time
      Person.validates_datetime :birth_datetime

      Person.timeliness_validated_attributes.should == {
        "birth_date" => :date,
        "birth_time" => :time,
        "birth_datetime" => :datetime
      }
    end
  end
end
