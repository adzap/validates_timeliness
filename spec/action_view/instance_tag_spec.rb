require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'ValidatesTimeliness::ActionView::InstanceTag' do
  include ActionView::Helpers::DateHelper
  include ActionController::Assertions::SelectorAssertions

  before do
    @person = Person.new
  end

  def params
    @params ||= {}
  end

  describe "datetime_select" do
    it "should use param values when attribute is nil" do
      params["person"] = {
        "birth_date_and_time(1i)" => 2009,
        "birth_date_and_time(2i)" => 2,
        "birth_date_and_time(3i)" => 29,
        "birth_date_and_time(4i)" => 12,
        "birth_date_and_time(5i)" => 13,
        "birth_date_and_time(6i)" => 14,
      }
      @person.birth_date_and_time = nil
      output = datetime_select(:person, :birth_date_and_time, :include_blank => true, :include_seconds => true)
      output.should have_tag('select[id=person_birth_date_and_time_1i] option[selected=selected]', '2009')
      output.should have_tag('select[id=person_birth_date_and_time_2i] option[selected=selected]', 'February')
      output.should have_tag('select[id=person_birth_date_and_time_3i] option[selected=selected]', '29')
      output.should have_tag('select[id=person_birth_date_and_time_4i] option[selected=selected]', '12')
      output.should have_tag('select[id=person_birth_date_and_time_5i] option[selected=selected]', '13')
      output.should have_tag('select[id=person_birth_date_and_time_6i] option[selected=selected]', '14')
    end

    it "should override object values and use params if present" do
      params["person"] = {
        "birth_date_and_time(1i)" => 2009,
        "birth_date_and_time(2i)" => 2,
        "birth_date_and_time(3i)" => 29,
        "birth_date_and_time(4i)" => 13,
        "birth_date_and_time(5i)" => 14,
        "birth_date_and_time(6i)" => 15,
      }
      @person.birth_date_and_time = "2009-03-01 13:14:15"
      output = datetime_select(:person, :birth_date_and_time, :include_blank => true, :include_seconds => true)
      output.should have_tag('select[id=person_birth_date_and_time_1i] option[selected=selected]', '2009')
      output.should have_tag('select[id=person_birth_date_and_time_2i] option[selected=selected]', 'February')
      output.should have_tag('select[id=person_birth_date_and_time_3i] option[selected=selected]', '29')
      output.should have_tag('select[id=person_birth_date_and_time_4i] option[selected=selected]', '13')
      output.should have_tag('select[id=person_birth_date_and_time_5i] option[selected=selected]', '14')
      output.should have_tag('select[id=person_birth_date_and_time_6i] option[selected=selected]', '15')
    end

    it "should select attribute values from object if no params" do
      @person.birth_date_and_time = "2009-01-02 13:14:15"
      output = datetime_select(:person, :birth_date_and_time, :include_blank => true, :include_seconds => true)
      output.should have_tag('select[id=person_birth_date_and_time_1i] option[selected=selected]', '2009')
      output.should have_tag('select[id=person_birth_date_and_time_2i] option[selected=selected]', 'January')
      output.should have_tag('select[id=person_birth_date_and_time_3i] option[selected=selected]', '2')
      output.should have_tag('select[id=person_birth_date_and_time_4i] option[selected=selected]', '13')
      output.should have_tag('select[id=person_birth_date_and_time_5i] option[selected=selected]', '14')
      output.should have_tag('select[id=person_birth_date_and_time_6i] option[selected=selected]', '15')
    end

    it "should select attribute values if params does not contain attribute params" do
      @person.birth_date_and_time = "2009-01-02 13:14:15"
      params["person"] = { }
      output = datetime_select(:person, :birth_date_and_time, :include_blank => true, :include_seconds => true)
      output.should have_tag('select[id=person_birth_date_and_time_1i] option[selected=selected]', '2009')
      output.should have_tag('select[id=person_birth_date_and_time_2i] option[selected=selected]', 'January')
      output.should have_tag('select[id=person_birth_date_and_time_3i] option[selected=selected]', '2')
      output.should have_tag('select[id=person_birth_date_and_time_4i] option[selected=selected]', '13')
      output.should have_tag('select[id=person_birth_date_and_time_5i] option[selected=selected]', '14')
      output.should have_tag('select[id=person_birth_date_and_time_6i] option[selected=selected]', '15')
    end

    it "should not select values when attribute value is nil and has no param values" do
      @person.birth_date_and_time = nil
      output = datetime_select(:person, :birth_date_and_time, :include_blank => true, :include_seconds => true)
      output.should_not have_tag('select[id=person_birth_date_and_time_1i] option[selected=selected]')
      output.should_not have_tag('select[id=person_birth_date_and_time_2i] option[selected=selected]')
      output.should_not have_tag('select[id=person_birth_date_and_time_3i] option[selected=selected]')
      output.should_not have_tag('select[id=person_birth_date_and_time_4i] option[selected=selected]')
      output.should_not have_tag('select[id=person_birth_date_and_time_5i] option[selected=selected]')
      output.should_not have_tag('select[id=person_birth_date_and_time_6i] option[selected=selected]')
    end
  end

  describe "date_select" do
    it "should use param values when attribute is nil" do
      params["person"] = {
        "birth_date(1i)" => 2009,
        "birth_date(2i)" => 2,
        "birth_date(3i)" => 29,
      }
      @person.birth_date = nil
      output = date_select(:person, :birth_date, :include_blank => true, :include_seconds => true)
      output.should have_tag('select[id=person_birth_date_1i] option[selected=selected]', '2009')
      output.should have_tag('select[id=person_birth_date_2i] option[selected=selected]', 'February')
      output.should have_tag('select[id=person_birth_date_3i] option[selected=selected]', '29')
    end

    it "should override object values and use params if present" do
      params["person"] = {
        "birth_date(1i)" => 2009,
        "birth_date(2i)" => 2,
        "birth_date(3i)" => 29,
      }
      @person.birth_date = "2009-03-01"
      output = date_select(:person, :birth_date, :include_blank => true, :include_seconds => true)
      output.should have_tag('select[id=person_birth_date_1i] option[selected=selected]', '2009')
      output.should have_tag('select[id=person_birth_date_2i] option[selected=selected]', 'February')
      output.should have_tag('select[id=person_birth_date_3i] option[selected=selected]', '29')
    end

    it "should select attribute values from object if no params" do
      @person.birth_date = "2009-01-02"
      output = date_select(:person, :birth_date, :include_blank => true, :include_seconds => true)
      output.should have_tag('select[id=person_birth_date_1i] option[selected=selected]', '2009')
      output.should have_tag('select[id=person_birth_date_2i] option[selected=selected]', 'January')
      output.should have_tag('select[id=person_birth_date_3i] option[selected=selected]', '2')
    end

    it "should select attribute values if params does not contain attribute params" do
      @person.birth_date = "2009-01-02"
      params["person"] = { }
      output = date_select(:person, :birth_date, :include_blank => true, :include_seconds => true)
      output.should have_tag('select[id=person_birth_date_1i] option[selected=selected]', '2009')
      output.should have_tag('select[id=person_birth_date_2i] option[selected=selected]', 'January')
      output.should have_tag('select[id=person_birth_date_3i] option[selected=selected]', '2')
    end

    it "should not select values when attribute value is nil and has no param values" do
      @person.birth_date = nil
      output = date_select(:person, :birth_date, :include_blank => true, :include_seconds => true)
      output.should_not have_tag('select[id=person_birth_date_1i] option[selected=selected]')
      output.should_not have_tag('select[id=person_birth_date_2i] option[selected=selected]')
      output.should_not have_tag('select[id=person_birth_date_3i] option[selected=selected]')
    end
  end

  describe "time_select" do
    before :all do
      Time.now = Time.mktime(2009,1,1)
    end

    it "should use param values when attribute is nil" do
      params["person"] = {
        "birth_time(1i)" => 2000,
        "birth_time(2i)" => 1,
        "birth_time(3i)" => 1,
        "birth_time(4i)" => 12,
        "birth_time(5i)" => 13,
        "birth_time(6i)" => 14,
      }
      @person.birth_time = nil
      output = time_select(:person, :birth_time, :include_blank => true, :include_seconds => true)
      output.should have_tag('input[id=person_birth_time_1i][value=2000]')
      output.should have_tag('input[id=person_birth_time_2i][value=1]')
      output.should have_tag('input[id=person_birth_time_3i][value=1]')
      output.should have_tag('select[id=person_birth_time_4i] option[selected=selected]', '12')
      output.should have_tag('select[id=person_birth_time_5i] option[selected=selected]', '13')
      output.should have_tag('select[id=person_birth_time_6i] option[selected=selected]', '14')
    end

    it "should select attribute values from object if no params" do
      @person.birth_time = "13:14:15"
      output = time_select(:person, :birth_time, :include_blank => true, :include_seconds => true)
      output.should have_tag('input[id=person_birth_time_1i][value=2000]')
      output.should have_tag('input[id=person_birth_time_2i][value=1]')
      output.should have_tag('input[id=person_birth_time_3i][value=1]')
      output.should have_tag('select[id=person_birth_time_4i] option[selected=selected]', '13')
      output.should have_tag('select[id=person_birth_time_5i] option[selected=selected]', '14')
      output.should have_tag('select[id=person_birth_time_6i] option[selected=selected]', '15')
    end

    it "should not select values when attribute value is nil and has no param values" do
      @person.birth_time = nil
      output = time_select(:person, :birth_time, :include_blank => true, :include_seconds => true)
      output.should have_tag('input[id=person_birth_time_1i][value=""]')
      # Annoyingly these may or not have value attribute depending on rails version.
      # output.should have_tag('input[id=person_birth_time_2i][value=""]')
      # output.should have_tag('input[id=person_birth_time_3i][value=""]')
      output.should_not have_tag('select[id=person_birth_time_4i] option[selected=selected]')
      output.should_not have_tag('select[id=person_birth_time_5i] option[selected=selected]')
      output.should_not have_tag('select[id=person_birth_time_6i] option[selected=selected]')
    end

    after :all do
      Time.now = nil
    end
  end

end
