require 'spec_helper'

describe ValidatesTimeliness::Extensions::DateTimeSelect do
  include ActionView::Helpers::DateHelper

  attr_reader :employee, :params

  before do
    @employee = Employee.new
    @params = {}
  end

  describe "datetime_select" do
    it "should use param values when attribute is nil" do
      params["employee"] = {
        "birth_datetime(1i)" => 2009,
        "birth_datetime(2i)" => 2,
        "birth_datetime(3i)" => 29,
        "birth_datetime(4i)" => 12,
        "birth_datetime(5i)" => 13,
        "birth_datetime(6i)" => 14,
      }
      employee.birth_datetime = nil
      output = datetime_select(:employee, :birth_datetime, :include_blank => true, :include_seconds => true)
      output.should have_tag('select[id=employee_birth_datetime_1i] option[selected=selected]', '2009')
      output.should have_tag('select[id=employee_birth_datetime_2i] option[selected=selected]', 'February')
      output.should have_tag('select[id=employee_birth_datetime_3i] option[selected=selected]', '29')
      output.should have_tag('select[id=employee_birth_datetime_4i] option[selected=selected]', '12')
      output.should have_tag('select[id=employee_birth_datetime_5i] option[selected=selected]', '13')
      output.should have_tag('select[id=employee_birth_datetime_6i] option[selected=selected]', '14')
    end

    it "should override object values and use params if present" do
      params["employee"] = {
        "birth_datetime(1i)" => 2009,
        "birth_datetime(2i)" => 2,
        "birth_datetime(3i)" => 29,
        "birth_datetime(4i)" => 12,
        "birth_datetime(5i)" => 13,
        "birth_datetime(6i)" => 14,
      }
      employee.birth_datetime = "2010-01-01 15:16:17"
      output = datetime_select(:employee, :birth_datetime, :include_blank => true, :include_seconds => true)
      output.should have_tag('select[id=employee_birth_datetime_1i] option[selected=selected]', '2009')
      output.should have_tag('select[id=employee_birth_datetime_2i] option[selected=selected]', 'February')
      output.should have_tag('select[id=employee_birth_datetime_3i] option[selected=selected]', '29')
      output.should have_tag('select[id=employee_birth_datetime_4i] option[selected=selected]', '12')
      output.should have_tag('select[id=employee_birth_datetime_5i] option[selected=selected]', '13')
      output.should have_tag('select[id=employee_birth_datetime_6i] option[selected=selected]', '14')
    end

    it "should use attribute values from object if no params" do
      employee.birth_datetime = "2009-01-02 12:13:14"
      output = datetime_select(:employee, :birth_datetime, :include_blank => true, :include_seconds => true)
      output.should have_tag('select[id=employee_birth_datetime_1i] option[selected=selected]', '2009')
      output.should have_tag('select[id=employee_birth_datetime_2i] option[selected=selected]', 'January')
      output.should have_tag('select[id=employee_birth_datetime_3i] option[selected=selected]', '2')
      output.should have_tag('select[id=employee_birth_datetime_4i] option[selected=selected]', '12')
      output.should have_tag('select[id=employee_birth_datetime_5i] option[selected=selected]', '13')
      output.should have_tag('select[id=employee_birth_datetime_6i] option[selected=selected]', '14')
    end

    it "should use attribute values if params does not contain attribute params" do
      employee.birth_datetime = "2009-01-02 12:13:14"
      params["employee"] = { }
      output = datetime_select(:employee, :birth_datetime, :include_blank => true, :include_seconds => true)
      output.should have_tag('select[id=employee_birth_datetime_1i] option[selected=selected]', '2009')
      output.should have_tag('select[id=employee_birth_datetime_2i] option[selected=selected]', 'January')
      output.should have_tag('select[id=employee_birth_datetime_3i] option[selected=selected]', '2')
      output.should have_tag('select[id=employee_birth_datetime_4i] option[selected=selected]', '12')
      output.should have_tag('select[id=employee_birth_datetime_5i] option[selected=selected]', '13')
      output.should have_tag('select[id=employee_birth_datetime_6i] option[selected=selected]', '14')
    end

    it "should not select values when attribute value is nil and has no param values" do
      employee.birth_datetime = nil
      output = datetime_select(:employee, :birth_datetime, :include_blank => true, :include_seconds => true)
      output.should_not have_tag('select[id=employee_birth_datetime_1i] option[selected=selected]')
      output.should_not have_tag('select[id=employee_birth_datetime_2i] option[selected=selected]')
      output.should_not have_tag('select[id=employee_birth_datetime_3i] option[selected=selected]')
      output.should_not have_tag('select[id=employee_birth_datetime_4i] option[selected=selected]')
      output.should_not have_tag('select[id=employee_birth_datetime_5i] option[selected=selected]')
      output.should_not have_tag('select[id=employee_birth_datetime_6i] option[selected=selected]')
    end
  end

  describe "date_select" do
    it "should use param values when attribute is nil" do
      params["employee"] = {
        "birth_date(1i)" => 2009,
        "birth_date(2i)" => 2,
        "birth_date(3i)" => 29,
      }
      employee.birth_date = nil
      output = date_select(:employee, :birth_date, :include_blank => true, :include_seconds => true)
      output.should have_tag('select[id=employee_birth_date_1i] option[selected=selected]', '2009')
      output.should have_tag('select[id=employee_birth_date_2i] option[selected=selected]', 'February')
      output.should have_tag('select[id=employee_birth_date_3i] option[selected=selected]', '29')
    end

    it "should override object values and use params if present" do
      params["employee"] = {
        "birth_date(1i)" => 2009,
        "birth_date(2i)" => 2,
        "birth_date(3i)" => 29,
      }
      employee.birth_date = "2009-03-01"
      output = date_select(:employee, :birth_date, :include_blank => true, :include_seconds => true)
      output.should have_tag('select[id=employee_birth_date_1i] option[selected=selected]', '2009')
      output.should have_tag('select[id=employee_birth_date_2i] option[selected=selected]', 'February')
      output.should have_tag('select[id=employee_birth_date_3i] option[selected=selected]', '29')
    end

    it "should select attribute values from object if no params" do
      employee.birth_date = "2009-01-02"
      output = date_select(:employee, :birth_date, :include_blank => true, :include_seconds => true)
      output.should have_tag('select[id=employee_birth_date_1i] option[selected=selected]', '2009')
      output.should have_tag('select[id=employee_birth_date_2i] option[selected=selected]', 'January')
      output.should have_tag('select[id=employee_birth_date_3i] option[selected=selected]', '2')
    end

    it "should select attribute values if params does not contain attribute params" do
      employee.birth_date = "2009-01-02"
      params["employee"] = { }
      output = date_select(:employee, :birth_date, :include_blank => true, :include_seconds => true)
      output.should have_tag('select[id=employee_birth_date_1i] option[selected=selected]', '2009')
      output.should have_tag('select[id=employee_birth_date_2i] option[selected=selected]', 'January')
      output.should have_tag('select[id=employee_birth_date_3i] option[selected=selected]', '2')
    end

    it "should not select values when attribute value is nil and has no param values" do
      employee.birth_date = nil
      output = date_select(:employee, :birth_date, :include_blank => true, :include_seconds => true)
      output.should_not have_tag('select[id=employee_birth_date_1i] option[selected=selected]')
      output.should_not have_tag('select[id=employee_birth_date_2i] option[selected=selected]')
      output.should_not have_tag('select[id=employee_birth_date_3i] option[selected=selected]')
    end
  end

  describe "time_select" do
    before do
      Timecop.freeze Time.mktime(2009,1,1)
    end

    it "should use param values when attribute is nil" do
      params["employee"] = {
        "birth_time(1i)" => 2000,
        "birth_time(2i)" => 1,
        "birth_time(3i)" => 1,
        "birth_time(4i)" => 12,
        "birth_time(5i)" => 13,
        "birth_time(6i)" => 14,
      }
      employee.birth_time = nil
      output = time_select(:employee, :birth_time, :include_blank => true, :include_seconds => true)
      output.should have_tag('select[id=employee_birth_time_4i] option[selected=selected]', '12')
      output.should have_tag('select[id=employee_birth_time_5i] option[selected=selected]', '13')
      output.should have_tag('select[id=employee_birth_time_6i] option[selected=selected]', '14')
    end

    it "should select attribute values from object if no params" do
      employee.birth_time = "2000-01-01 12:13:14"
      output = time_select(:employee, :birth_time, :include_blank => true, :include_seconds => true)
      output.should have_tag('select[id=employee_birth_time_4i] option[selected=selected]', '12')
      output.should have_tag('select[id=employee_birth_time_5i] option[selected=selected]', '13')
      output.should have_tag('select[id=employee_birth_time_6i] option[selected=selected]', '14')
    end

    it "should not select values when attribute value is nil and has no param values" do
      employee.birth_time = nil
      output = time_select(:employee, :birth_time, :include_blank => true, :include_seconds => true)
      output.should_not have_tag('select[id=employee_birth_time_4i] option[selected=selected]')
      output.should_not have_tag('select[id=employee_birth_time_5i] option[selected=selected]')
      output.should_not have_tag('select[id=employee_birth_time_6i] option[selected=selected]')
    end
  end

end
