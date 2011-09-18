require 'spec_helper'

describe ValidatesTimeliness::Extensions::DateTimeSelect do
  include ActionView::Helpers::DateHelper
  attr_reader :person, :params

  with_config(:use_plugin_parser, true)

  before do
    @person = Person.new
    @params = {}
  end

  describe "datetime_select" do
    it "should use param values when attribute is nil" do
      @params["person"] = {
        "birth_datetime(1i)" => '2009',
        "birth_datetime(2i)" => '2',
        "birth_datetime(3i)" => '29',
        "birth_datetime(4i)" => '12',
        "birth_datetime(5i)" => '13',
        "birth_datetime(6i)" => '14',
      }
      person.birth_datetime = nil
      @output = datetime_select(:person, :birth_datetime, :include_blank => true, :include_seconds => true)
      should_have_datetime_selected(:birth_datetime, :year => 2009, :month => 'February', :day => 29, :hour => 12, :min => 13, :sec => 14)
    end

    it "should override object values and use params if present" do
      @params["person"] = {
        "birth_datetime(1i)" => '2009',
        "birth_datetime(2i)" => '2',
        "birth_datetime(3i)" => '29',
        "birth_datetime(4i)" => '12',
        "birth_datetime(5i)" => '13',
        "birth_datetime(6i)" => '14',
      }
      person.birth_datetime = "2010-01-01 15:16:17"
      @output = datetime_select(:person, :birth_datetime, :include_blank => true, :include_seconds => true)
      should_have_datetime_selected(:birth_datetime, :year => 2009, :month => 'February', :day => 29, :hour => 12, :min => 13, :sec => 14)
    end

    it "should use attribute values from object if no params" do
      person.birth_datetime = "2009-01-02 12:13:14"
      @output = datetime_select(:person, :birth_datetime, :include_blank => true, :include_seconds => true)
      should_have_datetime_selected(:birth_datetime, :year => 2009, :month => 'January', :day => 2, :hour => 12, :min => 13, :sec => 14)
    end

    it "should use attribute values if params does not contain attribute params" do
      person.birth_datetime = "2009-01-02 12:13:14"
      @params["person"] = { }
      @output = datetime_select(:person, :birth_datetime, :include_blank => true, :include_seconds => true)
      should_have_datetime_selected(:birth_datetime, :year => 2009, :month => 'January', :day => 2, :hour => 12, :min => 13, :sec => 14)
    end

    it "should not select values when attribute value is nil and has no param values" do
      person.birth_datetime = nil
      @output = datetime_select(:person, :birth_datetime, :include_blank => true, :include_seconds => true)
      should_not_have_datetime_selected(:birth_datetime, :year, :month, :day, :hour, :min, :sec)
    end
  end

  describe "date_select" do
    it "should use param values when attribute is nil" do
      @params["person"] = {
        "birth_date(1i)" => '2009',
        "birth_date(2i)" => '2',
        "birth_date(3i)" => '29',
      }
      person.birth_date = nil
      @output = date_select(:person, :birth_date, :include_blank => true)
      should_have_datetime_selected(:birth_date, :year => 2009, :month => 'February', :day => 29)
    end

    it "should override object values and use params if present" do
      @params["person"] = {
        "birth_date(1i)" => '2009',
        "birth_date(2i)" => '2',
        "birth_date(3i)" => '29',
      }
      person.birth_date = "2009-03-01"
      @output = date_select(:person, :birth_date, :include_blank => true)
      should_have_datetime_selected(:birth_date, :year => 2009, :month => 'February', :day => 29)
    end

    it "should select attribute values from object if no params" do
      person.birth_date = "2009-01-02"
      @output = date_select(:person, :birth_date, :include_blank => true)
      should_have_datetime_selected(:birth_date, :year => 2009, :month => 'January', :day => 2)
    end

    it "should select attribute values if params does not contain attribute params" do
      person.birth_date = "2009-01-02"
      @params["person"] = { }
      @output = date_select(:person, :birth_date, :include_blank => true)
      should_have_datetime_selected(:birth_date, :year => 2009, :month => 'January', :day => 2)
    end

    it "should not select values when attribute value is nil and has no param values" do
      person.birth_date = nil
      @output = date_select(:person, :birth_date, :include_blank => true)
      should_not_have_datetime_selected(:birth_time, :year, :month, :day)
    end

    it "should allow the day part to be discarded" do
      @params["person"] = {
        "birth_date(1i)" => '2009',
        "birth_date(2i)" => '2',
      }

      @output = date_select(:person, :birth_date, :include_blank => true, :discard_day => true)
      should_have_datetime_selected(:birth_date, :year => 2009, :month => 'February')
      should_not_have_datetime_selected(:birth_time, :day)
      @output.should have_tag("input[id=person_birth_date_3i][type=hidden][value='1']")
    end
  end

  describe "time_select" do
    before do
      Timecop.freeze Time.mktime(2009,1,1)
    end

    it "should use param values when attribute is nil" do
      @params["person"] = {
        "birth_time(1i)" => '2000',
        "birth_time(2i)" => '1',
        "birth_time(3i)" => '1',
        "birth_time(4i)" => '12',
        "birth_time(5i)" => '13',
        "birth_time(6i)" => '14',
      }
      person.birth_time = nil
      @output = time_select(:person, :birth_time, :include_blank => true, :include_seconds => true)
      should_have_datetime_selected(:birth_time, :hour => 12, :min => 13, :sec => 14)
    end

    it "should select attribute values from object if no params" do
      person.birth_time = "2000-01-01 12:13:14"
      @output = time_select(:person, :birth_time, :include_blank => true, :include_seconds => true)
      should_have_datetime_selected(:birth_time, :hour => 12, :min => 13, :sec => 14)
    end

    it "should not select values when attribute value is nil and has no param values" do
      person.birth_time = nil
      @output = time_select(:person, :birth_time, :include_blank => true, :include_seconds => true)
      should_not_have_datetime_selected(:birth_time, :hour, :min, :sec)
    end
  end

  def should_have_datetime_selected(field, datetime_hash)
    datetime_hash.each do |key, value|
      index = {:year => 1, :month => 2, :day => 3, :hour => 4, :min => 5, :sec => 6}[key]
      @output.should have_tag("select[id=person_#{field}_#{index}i] option[selected=selected]", value.to_s)
    end
  end

  def should_not_have_datetime_selected(field, *attributes)
    attributes.each do |attribute|
      index = {:year => 1, :month => 2, :day => 3, :hour => 4, :min => 5, :sec => 6}[attribute]
      @output.should_not have_tag("select[id=person_#{attribute}_#{index}i] option[selected=selected]")
    end
  end
end
