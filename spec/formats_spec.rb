require File.dirname(__FILE__) + '/spec_helper'

describe ValidatesTimeliness::Formats do
  attr_reader :formats
  
  before do
   @formats = ValidatesTimeliness::Formats
  end
  
  describe "expression generator" do
    it "should generate regexp for time" do
      generate_regexp_str('hh:nn:ss').should == '/(\d{2}):(\d{2}):(\d{2})/'
    end
    
    it "should generate regexp for time with meridian" do
      generate_regexp_str('hh:nn:ss ampm').should == '/(\d{2}):(\d{2}):(\d{2}) ((?:a|p)\.?m\.?)/'
    end
    
    it "should generate regexp for time with meridian and optional space between" do
      generate_regexp_str('hh:nn:ss_ampm').should == '/(\d{2}):(\d{2}):(\d{2})\s?((?:a|p)\.?m\.?)/'
    end
    
    it "should generate regexp for time with single or double digits" do
      generate_regexp_str('h:n:s').should == '/(\d{1,2}):(\d{1,2}):(\d{1,2})/'
    end
    
    it "should generate regexp for date" do
      generate_regexp_str('yyyy-mm-dd').should == '/(\d{4})-(\d{2})-(\d{2})/'
    end
    
    it "should generate regexp for date with slashes" do
      generate_regexp_str('dd/mm/yyyy').should == '/(\d{2})\/(\d{2})\/(\d{4})/'
    end
   
    it "should generate regexp for date with dots" do
      generate_regexp_str('dd.mm.yyyy').should == '/(\d{2}).(\d{2}).(\d{4})/'
    end
   
    it "should generate regexp for Ruby time string" do
      expected = '/(\w{3,9}) (\w{3,9}) (\d{2}):(\d{2}):(\d{2}) (?:[+-]\d{2}:?\d{2}) (\d{4})/'
      generate_regexp_str('ddd mmm hh:nn:ss zo yyyy').should == expected
    end
    
    it "should generate regexp for iso8601 datetime" do
      expected = '/(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})(?:[+-]\d{2}:?\d{2})/'
      generate_regexp_str('yyyy-mm-ddThh:nn:sszo').should == expected
    end
  end
 
  describe "format proc generator" do
    it "should generate proc which outputs date array" do
      generate_proc('yyyy-mm-dd').call('2000', '1', '2').should == [2000,1,2,nil,nil,nil,nil]
    end
    
    it "should generate proc which outputs date array from format in non time array order" do
      generate_proc('dd/mm/yyyy').call('2', '1', '2000').should == [2000,1,2,nil,nil,nil,nil]
    end
    
    it "should generate proc which outputs time array" do
      generate_proc('hh:nn:ss').call('01', '02', '03').should == [nil,nil,nil,1,2,3,nil]
    end
    
    it "should generate proc which outputs time array with meridian adjusted hour" do
      generate_proc('hh:nn:ss ampm').call('01', '02', '03', 'pm').should == [nil,nil,nil,13,2,3,nil]
    end
    
    it "should generate proc which outputs time array with unadjusted hour" do
      generate_proc('hh:nn:ss ampm').call('01', '02', '03', 'am').should == [nil,nil,nil,1,2,3,nil]
    end
    
    it "should generate proc which outputs time array with microseconds" do
      generate_proc('hh:nn:ss.u').call('01', '02', '03', '99').should == [nil,nil,nil,1,2,3,99]
    end
  end
  
  describe "validation regexps" do    

    describe "for time formats" do
      format_tests = {  
        'hh:nn:ss' => {:pass => ['12:12:12', '01:01:01'], :fail => ['1:12:12', '12:1:12', '12:12:1', '12-12-12']},
        'hh-nn-ss' => {:pass => ['12-12-12', '01-01-01'], :fail => ['1-12-12', '12-1-12', '12-12-1', '12:12:12']},
        'hh:nn'    => {:pass => ['12:12', '01:01'], :fail => ['12:12:12', '12-12', '2:12']},
        'h.nn'     => {:pass => ['2.12', '12.12'], :fail => ['2.1', '12:12']}
#        'h nn',
#        'h-nn',
#        'h:nn_ampm',
#        'h.nn_ampm',
#        'h nn_ampm',
#        'h-nn_ampm',
#        'h_ampm'

      }    
      format_tests.each do |format, values|      
        it "should correctly match times in format '#{format}'" do
          regexp = generate_regexp(format)
          values[:pass].each {|value| value.should match(regexp)}
          values[:fail].each {|value| value.should_not match(regexp)}
        end
      end      
    end
    
  end
  
  describe "removing format" do
    before do
      formats.compile_format_expressions
    end
    
    it "should not match time after its format is removed" do      
      validate('12am', :time).should be_true
      formats.time_formats.delete('h_ampm')
      formats.compile_format_expressions
      validate('12am', :time).should be_false
    end
  end
 
  describe "adding format" do
    before do
      formats.compile_format_expressions
    end
    
    it "should not match time after its format is removed" do      
      validate("12 o'clock", :time).should be_false
      formats.time_formats << "h o'clock"
      formats.compile_format_expressions
      validate("12 o'clock", :time).should be_true
    end
  end
 
  def validate(time_string, type)
    valid = false
    formats.send("#{type}_expressions").each do |(regexp, processor)|
        valid = true and break if regexp =~ time_string
    end
    valid
  end
 
  def generate_regexp(format)
    # wrap in line start and end anchors to emulate extract values method
    /\A#{formats.format_expression_generator(format)[0]}\Z/
  end
  
  def generate_regexp_str(format)
    formats.format_expression_generator(format)[0].inspect
  end
  
  def generate_proc(format)
    formats.format_expression_generator(format)[1]
  end
  
  def delete_format(type, format)
    formats.send("#{type}_formats").delete(format)
  end
end
