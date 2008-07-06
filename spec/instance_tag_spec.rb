require File.dirname(__FILE__) + '/spec_helper'

describe ValidatesTimeliness::InstanceTag, :type => :helper do
  
  before do
    @person = Person.new
  end
  
  it "should return struct for time string" do
    @person.birth_date_and_time = "2008-02-30 12:00:00"
    output = date_select(:person, :birth_date_and_time, :include_blank => true)
    puts output
    output.should have_tag('select') do
      with_tag('input[type=text]', 3)
    end
  end

end
