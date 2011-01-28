require 'spec_helper'

describe ValidatesTimeliness::Validator, ":before option" do
  describe "for date type" do
    before do
      Person.validates_date :birth_date, :before => Date.new(2010, 1, 1)
    end

    it "should not be valid for date after restriction" do
      invalid!(:birth_date, Date.new(2010, 1, 2), 'must be before 2010-01-01')
    end

    it "should not be valid for same date value" do
      invalid!(:birth_date, Date.new(2010, 1, 1), 'must be before 2010-01-01')
    end

    it "should be valid for date before restriction" do
      valid!(:birth_date, Date.new(2009, 12, 31))
    end
  end

  describe "for time type" do
    before do
      Person.validates_time :birth_time, :before => Time.mktime(2000, 1, 1, 12, 0, 0)
    end

    it "should not be valid for time after restriction" do
      invalid!(:birth_time, Time.local_time(2000, 1, 1, 12, 00, 01), 'must be before 12:00:00')
    end

    it "should not be valid for same time as restriction" do
      invalid!(:birth_time, Time.local_time(2000, 1, 1, 12, 0, 0), 'must be before 12:00:00')
    end

    it "should be valid for time before restriction" do
      valid!(:birth_time, Time.local_time(2000, 1, 1, 11, 59, 59))
    end
  end

  describe "for datetime type" do
    before do
      Person.validates_datetime :birth_datetime, :before => DateTime.civil_from_format(:local, 2010, 1, 1, 12, 0, 0)
    end

    it "should not be valid for datetime after restriction" do
      invalid!(:birth_datetime, DateTime.civil_from_format(:local, 2010, 1, 1, 12, 0, 1), 'must be before 2010-01-01 12:00:00')
    end

    it "should not be valid for same datetime as restriction" do
      invalid!(:birth_datetime, DateTime.civil_from_format(:local, 2010, 1, 1, 12, 0, 0), 'must be before 2010-01-01 12:00:00')
    end

    it "should be valid for datetime before restriction" do
      valid!(:birth_datetime, DateTime.civil_from_format(:local, 2010, 1, 1, 11, 59, 59))
    end
  end
end
