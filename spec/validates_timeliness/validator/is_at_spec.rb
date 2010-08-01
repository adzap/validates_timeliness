require 'spec_helper'

describe ValidatesTimeliness::Validator, ":is_at option" do
  include ModelHelpers 

  before do
    Timecop.freeze(Time.local_time(2010, 1, 1, 0, 0, 0))
  end

  describe "for date type" do
    it "should be equal to same date value" do
      Person.validates_date :birth_date, :is_at => Date.new(2010, 1, 1)
      valid!(:birth_date, Date.new(2010, 1, 1))
    end

    it "should be equal to Time with same date part" do
      Person.validates_date :birth_date, :is_at => Time.local_time(2010, 1, 1, 0, 0, 0)
      valid!(:birth_date, Date.new(2010, 1, 1))
    end

    it "should be equal to DateTime with same date part" do
      Person.validates_date :birth_date, :is_at => DateTime.civil_from_format(:local, 2010, 1, 1, 0, 0, 0)
      valid!(:birth_date, Date.new(2010, 1, 1))
    end
  end

  describe "for time type" do
    it "should be equal to Date if attribute value is midnight" do
      Person.validates_time :birth_time, :is_at => Date.new(2010, 1, 1)
      valid!(:birth_time, Time.local_time(2000, 1, 1, 0, 0, 0))
    end

    it "should not be be equal to Date if attribute value is other than midnight" do
      Person.validates_time :birth_time, :is_at => Date.new(2010, 1, 1)
      invalid!(:birth_time, Time.local_time(2000, 1, 1, 9, 30, 0))
    end

    it "should be equal to local Time with same time part" do
      Person.validates_time :birth_time, :is_at => Time.local_time(2010, 1, 1, 0, 0, 0)
      valid!(:birth_time, Time.local_time(2000, 1, 1, 0, 0, 0))
    end

    it "should not be equal to UTC Time with same time part" do
      Person.validates_time :birth_time, :is_at => Time.utc(2010, 1, 1, 0, 0, 0)
      invalid!(:birth_time, Time.local_time(2000, 1, 1, 0, 0, 0))
    end

    it "should be equal to local DateTime with same time part" do
      Person.validates_time :birth_time, :is_at => DateTime.civil_from_format(:local, 2010, 1, 1, 0, 0, 0)
      valid!(:birth_time, Time.local_time(2000, 1, 1, 0, 0, 0))
    end

    it "should not be equal to UTC DateTime with same time part" do
      Person.validates_time :birth_time, :is_at => DateTime.new(2010, 1, 1, 0, 0, 0)
      invalid!(:birth_time, Time.local_time(2000, 1, 1, 0, 0, 0))
    end
  end

  describe "for datetime type" do
    it "should be equal to Date with same" do
      Person.validates_datetime :birth_datetime, :is_at => Date.new(2010, 1, 1)
      valid!(:birth_datetime, DateTime.civil_from_format(:local, 2010, 1, 1, 0, 0, 0))
    end

    it "should be equal to local Time with same component values" do
      Person.validates_datetime :birth_datetime, :is_at => Time.local_time(2010, 1, 1, 0, 0, 0)
      valid!(:birth_datetime, DateTime.civil_from_format(:local, 2010, 1, 1, 0, 0, 0))
    end

    it "should not be equal to UTC Time with same component values" do
      Person.validates_datetime :birth_datetime, :is_at => Time.utc(2010, 1, 1, 0, 0, 0)
      invalid!(:birth_datetime, DateTime.civil_from_format(:local, 2010, 1, 1, 0, 0, 0))
    end

    it "should be equal to same local DateTime value" do
      Person.validates_datetime :birth_datetime, :is_at => DateTime.civil_from_format(:local, 2010, 1, 1, 0, 0, 0)
      valid!(:birth_datetime, DateTime.civil_from_format(:local, 2010, 1, 1, 0, 0, 0))
    end

    it "should not be equal to UTC DateTime with same component values" do
      Person.validates_datetime :birth_datetime, :is_at => DateTime.new(2010, 1, 1, 0, 0, 0)
      invalid!(:birth_datetime, DateTime.civil_from_format(:local, 2010, 1, 1, 0, 0, 0))
    end
  end
end
