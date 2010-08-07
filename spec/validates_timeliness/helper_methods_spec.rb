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
    r = Employee.new
    r.validates_date :birth_date
    r.errors[:birth_date].should_not be_empty
  end

  describe ".timeliness_validated_attributes" do
    it 'should return attributes validated with plugin validator' do
      Person.validates_date :birth_date
      Person.timeliness_validated_attributes.should == ["birth_date"]
    end
  end
end
