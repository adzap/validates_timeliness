require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

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

  it "should not set values in datetime_select when datetime value is nil" do
    @person.birth_date_and_time = nil
    output = datetime_select(:person, :birth_date_and_time, :include_blank => true, :include_seconds => true)
    output.should have_tag('select[id=person_birth_date_and_time_1i]') do
      without_tag('option[selected=selected]')
    end
    output.should have_tag('select[id=person_birth_date_and_time_2i]') do
      without_tag('option[selected=selected]')
    end
    output.should have_tag('select[id=person_birth_date_and_time_3i]') do
      without_tag('option[selected=selected]')
    end
    output.should have_tag('select[id=person_birth_date_and_time_4i]') do
      without_tag('option[selected=selected]')
    end
    output.should have_tag('select[id=person_birth_date_and_time_5i]') do
      without_tag('option[selected=selected]')
    end
    output.should have_tag('select[id=person_birth_date_and_time_6i]') do
      without_tag('option[selected=selected]')
    end
  end

  it "should not set value in datetime_select where datetime string has empty value" do
    @person.birth_date_and_time = '2000-- ::'
    output = datetime_select(:person, :birth_date_and_time, :include_blank => true, :include_seconds => true)
    output.should have_tag('select[id=person_birth_date_and_time_1i]') do
      with_tag('option[selected=selected]')
    end
    output.should have_tag('select[id=person_birth_date_and_time_2i]') do
      without_tag('option[selected=selected]')
    end
    output.should have_tag('select[id=person_birth_date_and_time_3i]') do
      without_tag('option[selected=selected]')
    end
    output.should have_tag('select[id=person_birth_date_and_time_4i]') do
      without_tag('option[selected=selected]')
    end
    output.should have_tag('select[id=person_birth_date_and_time_5i]') do
      without_tag('option[selected=selected]')
    end
    output.should have_tag('select[id=person_birth_date_and_time_6i]') do
      without_tag('option[selected=selected]')
    end
  end
end
