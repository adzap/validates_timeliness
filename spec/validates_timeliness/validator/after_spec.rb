require 'spec_helper'

describe ValidatesTimeliness::Validator, ":after option" do
  describe "for date type" do
    before do
      Person.validates_date :birth_date, :after => Date.new(2010, 1, 1)
    end

    it "should not be valid for same date value" do
      invalid!(:birth_date, Date.new(2010, 1, 1), 'must be after 2010-01-01')
    end

    it "should not be valid for date before restriction" do
      invalid!(:birth_date, Date.new(2009, 12, 31), 'must be after 2010-01-01')
    end

    it "should be valid for date after restriction" do
      valid!(:birth_date, Date.new(2010, 1, 2))
    end
  end

  describe "for time type" do
    before do
      Person.validates_time :birth_time, :after => Time.mktime(2000, 1, 1, 12, 0, 0)
    end

    it "should not be valid for same time as restriction" do
      invalid!(:birth_time, Time.local_time(2000, 1, 1, 12, 0, 0), 'must be after 12:00:00')
    end

    it "should not be valid for time before restriction" do
      invalid!(:birth_time, Time.local_time(2000, 1, 1, 11, 59, 59), 'must be after 12:00:00')
    end

    it "should be valid for time after restriction" do
      valid!(:birth_time, Time.local_time(2000, 1, 1, 12, 00, 01))
    end
  end

  describe "for datetime type" do
    before do
      Person.validates_datetime :birth_datetime, :after => DateTime.civil_from_format(:local, 2010, 1, 1, 12, 0, 0)
    end

    it "should not be valid for same datetime as restriction" do
      invalid!(:birth_datetime, DateTime.civil_from_format(:local, 2010, 1, 1, 12, 0, 0), 'must be after 2010-01-01 12:00:00')
    end

    it "should be valid for datetime is before restriction" do
      invalid!(:birth_datetime, DateTime.civil_from_format(:local, 2010, 1, 1, 11, 59, 59), 'must be after 2010-01-01 12:00:00')
    end

    it "should be valid for datetime is after restriction" do
      valid!(:birth_datetime, DateTime.civil_from_format(:local, 2010, 1, 1, 12, 0, 1))
    end
  end
end
