require 'spec_helper'

describe ValidatesTimeliness::Validator, ":is_at option" do
  before do
    Timecop.freeze(Time.local_time(2010, 1, 1, 0, 0, 0))
  end

  describe "for date type" do
    before do
      Person.validates_date :birth_date, :is_at => Date.new(2010, 1, 1)
    end

    it "should not be valid for date before restriction" do
      invalid!(:birth_date, Date.new(2009, 12, 31), 'must be at 2010-01-01')
    end

    it "should not be valid for date after restriction" do
      invalid!(:birth_date, Date.new(2010, 1, 2), 'must be at 2010-01-01')
    end

    it "should be valid for same date value" do
      valid!(:birth_date, Date.new(2010, 1, 1))
    end
  end

  describe "for time type" do
    before do
      Person.validates_time :birth_time, :is_at => Time.mktime(2000, 1, 1, 12, 0, 0)
    end

    it "should not be valid for time before restriction" do
      invalid!(:birth_time, Time.local_time(2000, 1, 1, 11, 59, 59), 'must be at 12:00:00')
    end

    it "should not be valid for time after restriction" do
      invalid!(:birth_time, Time.local_time(2000, 1, 1, 12, 00, 01), 'must be at 12:00:00')
    end

    it "should be valid for same time as restriction" do
      valid!(:birth_time, Time.local_time(2000, 1, 1, 12, 0, 0))
    end
  end

  describe "for datetime type" do
    before do
      Person.validates_datetime :birth_datetime, :is_at => DateTime.civil_from_format(:local, 2010, 1, 1, 12, 0, 0)
    end

    it "should not be valid for datetime before restriction" do
      invalid!(:birth_datetime, DateTime.civil_from_format(:local, 2010, 1, 1, 11, 59, 59), 'must be at 2010-01-01 12:00:00')
    end

    it "should not be valid for datetime after restriction" do
      invalid!(:birth_datetime, DateTime.civil_from_format(:local, 2010, 1, 1, 12, 0, 1), 'must be at 2010-01-01 12:00:00')
    end

    it "should be valid for same datetime as restriction" do
      valid!(:birth_datetime, DateTime.civil_from_format(:local, 2010, 1, 1, 12, 0, 0))
    end
  end
end
