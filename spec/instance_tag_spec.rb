require File.dirname(__FILE__) + '/spec_helper'

describe ValidatesTimeliness::InstanceTag, :type => :helper do
  
  before do
    @person = Person.new
  end
  
  it "should display invalid date as date_select values" do
    @person.birth_date_and_time = "2008-02-30 12:00:00"
    output = date_select(:person, :birth_date_and_time, :include_blank => true)
   
    output.should have_tag('select[id=person_birth_date_and_time_1i]') do
      with_tag('option[selected=selected]', '2008')
    end
    output.should have_tag('select[id=person_birth_date_and_time_2i]') do
      with_tag('option[selected=selected]', 'February')
    end
    output.should have_tag('select[id=person_birth_date_and_time_3i]') do
      with_tag('option[selected=selected]', '30')
    end
  end
end
