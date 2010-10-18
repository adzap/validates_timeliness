require 'spec_helper'

describe ValidatesTimeliness do

  it 'should alias use_euro_formats to remove_us_formats on Timeliness gem' do
    Timeliness.should respond_to(:remove_us_formats) 
  end

  it 'should alias to date_for_time_type to dummy_date_for_time_type on Timeliness gem' do
    Timeliness.should respond_to(:dummy_date_for_time_type) 
  end

  describe "config" do
    it 'should delegate default_timezone to Timeliness gem' do
      Timeliness.should_receive(:default_timezone=)
      ValidatesTimeliness.default_timezone = :utc
    end

    it 'should delegate dummy_date_for_time_type to Timeliness gem' do
      Timeliness.should_receive(:dummy_date_for_time_type) 
      Timeliness.should_receive(:dummy_date_for_time_type=) 
      array = ValidatesTimeliness.dummy_date_for_time_type
      ValidatesTimeliness.dummy_date_for_time_type = array
    end

    context "parser" do
      it 'should delegate add_formats to Timeliness gem' do
        Timeliness.should_receive(:add_formats)
        ValidatesTimeliness.parser.add_formats
      end

      it 'should delegate remove_formats to Timeliness gem' do
        Timeliness.should_receive(:remove_formats)
        ValidatesTimeliness.parser.remove_formats
      end

      it 'should delegate remove_us_formats to Timeliness gem' do
        Timeliness.should_receive(:remove_us_formats)
        ValidatesTimeliness.parser.remove_us_formats
      end
    end
  end
end
