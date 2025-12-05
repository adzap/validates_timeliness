describe Timeliness::Helpers do
  include Timeliness::Helpers

  describe "#full_hour" do
    it "should convert a 12-hour clock AM time to 24-hour format correctly" do
      expect(full_hour(12, 'am')).to eq 0
      expect(full_hour(1, 'am')).to eq 1
      expect(full_hour(10, 'am')).to eq 10
    end

    it "should convert a 12-hour clock PM time to 24-hour format correctly" do
      expect(full_hour(12, 'pm')).to eq 12
      expect(full_hour(1, 'pm')).to eq 13
      expect(full_hour(10, 'pm')).to eq 22
    end

    it "should raise ArgumentError when given an hour of 0 with AM meridian" do
      expect { full_hour(0, 'am') }.to raise_error(ArgumentError)
    end

    it "should raise ArgumentError when given an hour greater than 12 with AM meridian" do
      expect { full_hour(13, 'am') }.to raise_error(ArgumentError)
    end

    it "should handle meridian strings with periods" do
      expect(full_hour(10, 'A.M.')).to eq 10
      expect(full_hour(10, 'P.M.')).to eq 22
      expect(full_hour(12, 'A.M.')).to eq 0
      expect(full_hour(12, 'P.M.')).to eq 12
    end
  end

  describe "#unambiguous_year" do
    before do
      @original_threshold = Timeliness.configuration.ambiguous_year_threshold
      Timeliness.configuration.ambiguous_year_threshold = 30
      Timecop.freeze(Time.new(2023, 1, 1))
    end

    after do
      Timeliness.configuration.ambiguous_year_threshold = @original_threshold
      Timecop.return
    end

    it "should convert 2-digit years to 4-digit years based on the current century and ambiguous year threshold" do
      # Current century (21st) for years below threshold
      expect(unambiguous_year('29')).to eq 2029

      # Previous century (20th) for years above or equal to threshold
      expect(unambiguous_year('30')).to eq 1930
      expect(unambiguous_year('99')).to eq 1999

      # Should not modify years that are already 4-digits
      expect(unambiguous_year('2023')).to eq 2023

      # Should handle single digit years with padding
      expect(unambiguous_year('7')).to eq 2007

      # Should handle years at century boundaries
      expect(unambiguous_year('00')).to eq 2000
    end
  end

  describe "#month_index" do
    before do
      allow(self).to receive(:i18n_loaded?).and_return(false)
    end

    it "should correctly parse month names as month indices regardless of case" do
      # Testing with full month names
      expect(month_index("january")).to eq 1
      expect(month_index("MARCH")).to eq 3
      expect(month_index("DeCeMbEr")).to eq 12

      # Testing with abbreviated month names
      expect(month_index("jan")).to eq 1
      expect(month_index("MAR")).to eq 3
      expect(month_index("deC")).to eq 12

      # Testing with numeric month
      expect(month_index("7")).to eq 7
    end
  end

  describe "#microseconds" do
    it "should convert microsecond strings to integer microsecond values" do
      expect(microseconds('0')).to eq 0
      expect(microseconds('1')).to eq 100000
      expect(microseconds('01')).to eq 10000
      expect(microseconds('001')).to eq 1000
      expect(microseconds('9')).to eq 900000
      expect(microseconds('99')).to eq 990000
      expect(microseconds('999')).to eq 999000
      expect(microseconds('999999')).to eq 999999
    end
  end

  describe "#offset_in_seconds" do
    it "should calculate offset in seconds from timezone string formats" do
      # Standard format with colon
      expect(offset_in_seconds('+10:00')).to eq 36000
      expect(offset_in_seconds('-05:30')).to eq -19800

      # Format without colon
      expect(offset_in_seconds('+1030')).to eq 37800
      expect(offset_in_seconds('-0530')).to eq -19800

      # Default positive sign when omitted
      expect(offset_in_seconds('08:00')).to eq 28800

      # Zero offset
      expect(offset_in_seconds('+00:00')).to eq 0
      expect(offset_in_seconds('-00:00')).to eq 0
    end
  end
end
