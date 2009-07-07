require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')
require 'validates_timeliness/matcher'

class NoValidation < Person
end

class WithValidation < Person
  validates_date :birth_date, 
    :equal_to     => '2000-01-01',
    :before       => '2000-01-10',
    :after        => '2000-01-01',
    :on_or_before => '2000-01-09',
    :on_or_after  => '2000-01-02',
    :between      => ['2000-01-01', '2000-01-03']

  validates_time :birth_time, 
    :equal_to     => '09:00',
    :before       => '23:00',
    :after        => '09:00',
    :on_or_before => '22:00',
    :on_or_after  => '10:00',
    :between      => ['09:00', '17:00']

  validates_datetime :birth_date_and_time, 
    :equal_to     => '2000-01-01 09:00',
    :before       => '2000-01-10 23:00',
    :after        => '2000-01-01 09:00',
    :on_or_before => '2000-01-09 23:00',
    :on_or_after  => '2000-01-02 09:00',
    :between      => ['2000-01-01 09:00', '2000-01-01 17:00']

end

class CustomMessages < Person
  validates_date :birth_date,
    :invalid_date_message => 'is not really a date',
    :before               => '2000-01-10',
    :before_message       => 'is too late',
    :after                => '2000-01-01',
    :after_message        => 'is too early',
    :on_or_before         => '2000-01-09',
    :on_or_before_message => 'is just too late',
    :on_or_after          => '2000-01-02',
    :on_or_after_message  => 'is just too early'
end

describe "ValidateTimeliness matcher" do
  attr_accessor :no_validation, :with_validation
  
  @@attribute_for_type = { :date => :birth_date, :time => :birth_time, :datetime => :birth_date_and_time }
  
  before do
    @no_validation = NoValidation.new
    @with_validation = WithValidation.new
  end

  [:date, :time, :datetime].each do |type|
    
    it "should report that #{type} is validated" do
      with_validation.should self.send("validate_#{type}", attribute_for_type(type))
    end
    
    it "should report that #{type} is not validated" do
      no_validation.should_not self.send("validate_#{type}", attribute_for_type(type))
    end    
  end
   
  describe "with equal_to option" do
    test_values = {
      :date     => ['2000-01-01', '2000-01-02'],
      :time     => ['09:00', '09:01'],
      :datetime => ['2000-01-01 09:00', '2000-01-01 09:01']
    }
    
    [:date, :time, :datetime].each do |type|

      it "should report that #{type} is validated" do
        with_validation.should self.send("validate_#{type}", attribute_for_type(type), :equal_to => test_values[type][0])
      end
      
      it "should report that #{type} is not validated when option value is incorrect" do
        with_validation.should_not self.send("validate_#{type}", attribute_for_type(type), :equal_to => test_values[type][1])
      end
      
      it "should report that #{type} is not validated with option" do
        no_validation.should_not self.send("validate_#{type}", attribute_for_type(type), :equal_to => test_values[type][0])
      end
    end
  end

  describe "with before option" do
    test_values = {
      :date     => ['2000-01-10', '2000-01-11'],
      :time     => ['23:00', '22:59'],
      :datetime => ['2000-01-10 23:00', '2000-01-10 22:59']  
    }
    
    [:date, :time, :datetime].each do |type|

      it "should report that #{type} is validated" do
        with_validation.should self.send("validate_#{type}", attribute_for_type(type), :before => test_values[type][0])
      end
      
      it "should report that #{type} is not validated when option value is incorrect" do
        with_validation.should_not self.send("validate_#{type}", attribute_for_type(type), :before => test_values[type][1])
      end
      
      it "should report that #{type} is not validated with option" do
        no_validation.should_not self.send("validate_#{type}", attribute_for_type(type), :before => test_values[type][0])
      end
    end
  end
    
  describe "with after option" do
    test_values = {
      :date     => ['2000-01-01', '2000-01-02'],
      :time     => ['09:00', '09:01'],
      :datetime => ['2000-01-01 09:00', '2000-01-01 09:01']  
    }
    
    [:date, :time, :datetime].each do |type|

      it "should report that #{type} is validated" do
        with_validation.should self.send("validate_#{type}", attribute_for_type(type), :after => test_values[type][0])
      end
      
      it "should report that #{type} is not validated when option value is incorrect" do
        with_validation.should_not self.send("validate_#{type}", attribute_for_type(type), :after => test_values[type][1])
      end
      
      it "should report that #{type} is not validated with option" do
        no_validation.should_not self.send("validate_#{type}", attribute_for_type(type), :after => test_values[type][0])
      end
    end
  end
  
  describe "with on_or_before option" do
    test_values = {
      :date     => ['2000-01-09', '2000-01-08'],
      :time     => ['22:00', '21:59'],
      :datetime => ['2000-01-09 23:00', '2000-01-09 22:59']  
    }
    
    [:date, :time, :datetime].each do |type|

      it "should report that #{type} is validated" do
        with_validation.should self.send("validate_#{type}", attribute_for_type(type), :on_or_before => test_values[type][0])
      end
      
      it "should report that #{type} is not validated when option value is incorrect" do
        with_validation.should_not self.send("validate_#{type}", attribute_for_type(type), :on_or_before => test_values[type][1])
      end
      
      it "should report that #{type} is not validated with option" do
        no_validation.should_not self.send("validate_#{type}", attribute_for_type(type), :on_or_before => test_values[type][0])
      end
    end
  end
  
  describe "with on_or_after option" do
    test_values = {
      :date     => ['2000-01-02', '2000-01-03'],
      :time     => ['10:00', '10:01'],
      :datetime => ['2000-01-02 09:00', '2000-01-02 09:01']  
    }
    
    [:date, :time, :datetime].each do |type|

      it "should report that #{type} is validated" do
        with_validation.should self.send("validate_#{type}", attribute_for_type(type), :on_or_after => test_values[type][0])
      end
      
      it "should report that #{type} is not validated when option value is incorrect" do
        with_validation.should_not self.send("validate_#{type}", attribute_for_type(type), :on_or_after => test_values[type][1])
      end
      
      it "should report that #{type} is not validated with option" do
        no_validation.should_not self.send("validate_#{type}", attribute_for_type(type), :on_or_after => test_values[type][0])
      end
    end
  end
  
  describe "between option" do
    test_values = {
      :date     => [ ['2000-01-01', '2000-01-03'], ['2000-01-01', '2000-01-04'] ],
      :time     => [ ['09:00', '17:00'], ['09:00', '17:01'] ], 
      :datetime => [ ['2000-01-01 09:00', '2000-01-01 17:00'], ['2000-01-01 09:00', '2000-01-01 17:01'] ] 
    }
    
    [:date, :time, :datetime].each do |type|

      it "should report that #{type} is validated" do
        with_validation.should self.send("validate_#{type}", attribute_for_type(type), :between => test_values[type][0])
      end
      
      it "should report that #{type} is not validated when option value is incorrect" do
        with_validation.should_not self.send("validate_#{type}", attribute_for_type(type), :between => test_values[type][1])
      end
      
      it "should report that #{type} is not validated with option" do
        no_validation.should_not self.send("validate_#{type}", attribute_for_type(type), :between => test_values[type][0])
      end
    end
  end

  describe "custom messages" do

    before do
      @person = CustomMessages.new
    end
    
    it "should match error message for invalid" do
      @person.should validate_date(:birth_date, :invalid_date_message => 'is not really a date')
    end
    
    it "should match error message for before option" do
      @person.should validate_date(:birth_date, :before => '2000-01-10', 
        :invalid_date_message => 'is not really a date',
        :before_message => 'is too late')
    end
     
    it "should match error message for after option" do
      @person.should validate_date(:birth_date, :after => '2000-01-01', 
        :invalid_date_message => 'is not really a date',
        :after_message => 'is too early')
    end 

    it "should match error message for on_or_before option" do
      @person.should validate_date(:birth_date, :on_or_before => '2000-01-09',
        :invalid_date_message => 'is not really a date',
        :on_or_before_message => 'is just too late')
    end
    
    it "should match error message for on_or_after option" do
      @person.should validate_date(:birth_date, :on_or_after => '2000-01-02',
        :invalid_date_message => 'is not really a date',
        :on_or_after_message => 'is just too early')
    end
    
  end

  def attribute_for_type(type)
    @@attribute_for_type[type.to_sym]
  end
end
