require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

ValidatesTimeliness.enable_datetime_select_extension!

describe 'ValidatesTimeliness::ActionView::InstanceTag' do
  include ActionView::Helpers::DateHelper
  include ActionController::Assertions::SelectorAssertions
  
  before do
    @person = Person.new
  end
  
  it "should display invalid datetime as datetime_select values" do
    @person.birth_date_and_time = "2008-02-30 12:00:22"
    output = datetime_select(:person, :birth_date_and_time, :include_blank => true, :include_seconds => true)
   
    output.should have_tag('select[id=person_birth_date_and_time_1i]') do
      with_tag('option[selected=selected]', '2008')
    end
    output.should have_tag('select[id=person_birth_date_and_time_2i]') do
      with_tag('option[selected=selected]', 'February')
    end
    output.should have_tag('select[id=person_birth_date_and_time_3i]') do
      with_tag('option[selected=selected]', '30')
    end
    output.should have_tag('select[id=person_birth_date_and_time_4i]') do
      with_tag('option[selected=selected]', '12')
    end
    output.should have_tag('select[id=person_birth_date_and_time_5i]') do
      with_tag('option[selected=selected]', '00')
    end
    output.should have_tag('select[id=person_birth_date_and_time_6i]') do
      with_tag('option[selected=selected]', '22')
    end
  end
  
  it "should display datetime_select when datetime value is nil" do
    @person.birth_date_and_time = nil
    output = datetime_select(:person, :birth_date_and_time, :include_blank => true, :include_seconds => true)
    output.should have_tag('select', 6)
  end
end
