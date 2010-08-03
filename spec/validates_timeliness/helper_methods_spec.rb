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
end
