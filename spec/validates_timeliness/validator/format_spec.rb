class FormatTestModel
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations
  include ValidatesTimeliness::ORM::ActiveModel

  attribute :date, :date, default: Date.new
  attribute :time, :time, default: Time.new
  attribute :datetime, :time, default: DateTime.new

  validates :date, timeliness: {type: :date, format: "yyyy-mm-dd"}
  validates :time, timeliness: {type: :time, format: "hh:nn:ss"}
  validates :datetime, timeliness: {type: :datetime, format: "yyyy-mm-dd hh:nn:ss"}
end

RSpec.describe ValidatesTimeliness::Validator, ":format option" do
  describe "for date type" do
    it "should not be valid for string given in the wrong format" do
      model = FormatTestModel.new(date: "01-01-2010")

      expect(model).to_not be_valid
      expect(model.errors.messages_for(:date)).to eq(["is not a valid date"])
    end

    it "should be valid for string given in the right format" do
      model = FormatTestModel.new(date: "2010-01-01")

      expect(model).to be_valid, -> { model.errors.full_messages.join("\n") }
    end

    it "should be valid for date instance" do
      model = FormatTestModel.new(date: Date.new(2010, 1, 1))

      expect(model).to be_valid, -> { model.errors.full_messages.join("\n") }
    end
  end

  describe "for time type" do
    it "should not be valid for string given in the wrong format" do
      model = FormatTestModel.new(time: "00-00-00")

      expect(model).to_not be_valid
      expect(model.errors.messages_for(:time)).to eq(["is not a valid time"])
    end

    it "should be valid for string given in the right format" do
      model = FormatTestModel.new(time: "00:00:00")

      expect(model).to be_valid, -> { model.errors.full_messages.join("\n") }
    end

    it "should be valid for date instance" do
      model = FormatTestModel.new(time: Time.new(2010, 1, 1, 0, 0, 0))

      expect(model).to be_valid, -> { model.errors.full_messages.join("\n") }
    end
  end

  describe "for datetime type" do
    it "should not be valid for string given in the wrong format" do
      model = FormatTestModel.new(datetime: "01-01-2010 00-00-00")

      expect(model).to_not be_valid
      expect(model.errors.messages_for(:datetime)).to eq(["is not a valid datetime"])
    end

    it "should be valid for string given in the right format" do
      model = FormatTestModel.new(datetime: "2010-01-01 00:00:00")

      expect(model).to be_valid, -> { model.errors.full_messages.join("\n") }
    end

    it "should be valid for date instance" do
      model = FormatTestModel.new(datetime: DateTime.new(2010, 1, 1, 0, 0, 0))

      expect(model).to be_valid, -> { model.errors.full_messages.join("\n") }
    end
  end
end
