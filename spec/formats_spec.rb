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
      generate_regexp_str('dd.mm.yyyy').should == '/(\d{2})\.(\d{2})\.(\d{4})/'
    end
   
    it "should generate regexp for Ruby time string" do
      expected = '/(\w{3,9}) (\w{3,9}) (\d{2}):(\d{2}):(\d{2}) (?:[+-]\d{2}:?\d{2}) (\d{4})/'
      generate_regexp_str('ddd mmm hh:nn:ss zo yyyy').should == expected
    end
    
    it "should generate regexp for iso8601 datetime" do
      expected = '/(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})(?:Z|(?:[+-]\d{2}:?\d{2}))/'
      generate_regexp_str('yyyy-mm-ddThh:nn:ss(?:Z|zo)').should == expected
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
    
    it "should generate proc which outputs time array with meridian 'pm' adjusted hour" do
      generate_proc('hh:nn:ss ampm').call('01', '02', '03', 'pm').should == [nil,nil,nil,13,2,3,nil]
    end
    
    it "should generate proc which outputs time array with meridian 'am' unadjusted hour" do
      generate_proc('hh:nn:ss ampm').call('01', '02', '03', 'am').should == [nil,nil,nil,1,2,3,nil]
    end
    
    it "should generate proc which outputs time array with microseconds" do
      generate_proc('hh:nn:ss.u').call('01', '02', '03', '99').should == [nil,nil,nil,1,2,3,99]
    end
  end
  
  describe "validation regexps" do
  
    describe "for time formats" do
      format_tests = {  
        'hh:nn:ss'  => {:pass => ['12:12:12', '01:01:01'], :fail => ['1:12:12', '12:1:12', '12:12:1', '12-12-12']},
        'hh-nn-ss'  => {:pass => ['12-12-12', '01-01-01'], :fail => ['1-12-12', '12-1-12', '12-12-1', '12:12:12']},
        'h:nn'      => {:pass => ['12:12', '1:01'], :fail => ['12:2', '12-12']},
        'h.nn'      => {:pass => ['2.12', '12.12'], :fail => ['2.1', '12:12']},
        'h nn'      => {:pass => ['2 12', '12 12'], :fail => ['2 1', '2.12', '12:12']},
        'h-nn'      => {:pass => ['2-12', '12-12'], :fail => ['2-1', '2.12', '12:12']},
        'h:nn_ampm' => {:pass => ['2:12am', '2:12 pm'], :fail => ['1:2am', '1:12  pm', '2.12am']},
        'h.nn_ampm' => {:pass => ['2.12am', '2.12 pm'], :fail => ['1:2am', '1:12  pm', '2:12am']},
        'h nn_ampm' => {:pass => ['2 12am', '2 12 pm'], :fail => ['1 2am', '1 12  pm', '2:12am']},
        'h-nn_ampm' => {:pass => ['2-12am', '2-12 pm'], :fail => ['1-2am', '1-12  pm', '2:12am']},
        'h_ampm'    => {:pass => ['2am', '2 am', '12 pm'], :fail => ['1.am', '12  pm', '2:12am']},
      }    
      format_tests.each do |format, values|      
        it "should correctly validate times in format '#{format}'" do
          regexp = generate_regexp(format)
          values[:pass].each {|value| value.should match(regexp)}
          values[:fail].each {|value| value.should_not match(regexp)}
        end
      end      
    end
    
    describe "for date formats" do
      format_tests = {
        'yyyy/mm/dd' => {:pass => ['2000/02/01'], :fail => ['2000\02\01', '2000/2/1', '00/02/01']},
        'yyyy-mm-dd' => {:pass => ['2000-02-01'], :fail => ['2000\02\01', '2000-2-1', '00-02-01']},
        'yyyy.mm.dd' => {:pass => ['2000.02.01'], :fail => ['2000\02\01', '2000.2.1', '00.02.01']},
        'm/d/yy'     => {:pass => ['2/1/01', '02/01/00', '02/01/2000'], :fail => ['2/1/0', '2.1.01']},
        'd/m/yy'     => {:pass => ['1/2/01', '01/02/00', '01/02/2000'], :fail => ['1/2/0', '1.2.01']},
        'm\d\yy'     => {:pass => ['2\1\01', '2\01\00', '02\01\2000'], :fail => ['2\1\0', '2/1/01']},
        'd\m\yy'     => {:pass => ['1\2\01', '1\02\00', '01\02\2000'], :fail => ['1\2\0', '1/2/01']},
        'd-m-yy'     => {:pass => ['1-2-01', '1-02-00', '01-02-2000'], :fail => ['1-2-0', '1/2/01']},
        'd.m.yy'     => {:pass => ['1.2.01', '1.02.00', '01.02.2000'], :fail => ['1.2.0', '1/2/01']},
        'd mmm yy'   => {:pass => ['1 Feb 00', '1 Feb 2000', '1 February 00', '01 February 2000'], 
                          :fail => ['1 Fe 00', 'Feb 1 2000', '1 Feb 0']}
      }    
      format_tests.each do |format, values|      
        it "should correctly validate dates in format '#{format}'" do
          regexp = generate_regexp(format)
          values[:pass].each {|value| value.should match(regexp)}
          values[:fail].each {|value| value.should_not match(regexp)}
        end
      end      
    end
  end
  
  describe "removing formats" do
    before do
      formats.compile_format_expressions
    end
    
    it "should remove format from format array" do      
      formats.remove_formats(:time, 'h.nn_ampm')
      formats.time_formats.should_not include("h o'clock")
    end
    
    it "should not match time after its format is removed" do      
      validate('2.12am', :time).should be_true
      formats.remove_formats(:time, 'h.nn_ampm')
      validate('2.12am', :time).should be_false
    end
    
    after do
      formats.time_formats << 'h.nn_ampm'
    end
  end
 
  describe "adding formats" do  
    before do
      formats.compile_format_expressions
    end
    
    it "should add format to format array" do      
      formats.add_formats(:time, "h o'clock")
      formats.time_formats.should include("h o'clock")
    end
    
    it "should match new format after its added" do      
      validate("12 o'clock", :time).should be_false
      formats.add_formats(:time, "h o'clock")
      validate("12 o'clock", :time).should be_true
    end
    
    after do
      formats.time_formats.delete("h o'clock")
    end
  end
 
  def validate(time_string, type)
    valid = false
    formats.send("#{type}_expressions").each do |(regexp, processor)|
        valid = true and break if /\A#{regexp}\Z/ =~ time_string
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
