require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe ValidatesTimeliness::Validator do
  attr_accessor :person

  before :each do
    @person = Person.new
  end

  describe "timeliness_restriction_value" do
    it "should return Time object when restriction is Time object" do
      restriction_value(Time.now, person, :datetime).should be_kind_of(Time)
    end
    
    it "should return Time object when restriction is string" do
      restriction_value("2007-01-01 12:00", person, :datetime).should be_kind_of(Time)
    end
    
    it "should return Time object when restriction is method symbol which returns Time object" do
      person.stub!(:datetime_attr).and_return(Time.now)
      restriction_value(:datetime_attr, person, :datetime).should be_kind_of(Time)
    end
    
    it "should return Time object when restriction is method symbol which returns string" do
      person.stub!(:datetime_attr).and_return("2007-01-01 12:00")
      restriction_value(:datetime_attr, person, :datetime).should be_kind_of(Time)
    end
    
    it "should return Time object when restriction is proc which returns Time object" do
      restriction_value(lambda { Time.now }, person, :datetime).should be_kind_of(Time)
    end
    
    it "should return Time object when restriction is proc which returns string" do
      restriction_value(lambda {"2007-01-01 12:00"}, person, :datetime).should be_kind_of(Time)
    end
    
    def restriction_value(*args)
      ValidatesTimeliness::Validator.send(:restriction_value, *args)
    end
  end

end
