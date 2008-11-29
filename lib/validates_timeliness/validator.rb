module ValidatesTimeliness

  # Adds ActiveRecord validation methods for date, time and datetime validation.
  # The validity of values can be restricted to be before or after certain dates
  # or times.
  class Validator
    attr_accessor :configuration, :errors

    cattr_accessor :ignore_datetime_restriction_errors
    cattr_accessor :date_time_error_value_formats
    cattr_accessor :default_error_messages
    
    @@ignore_datetime_restriction_errors = false
      
    @@date_time_error_value_formats = {
      :time     => '%H:%M:%S',
      :date     => '%Y-%m-%d',
      :datetime => '%Y-%m-%d %H:%M:%S'
    }      
      
    @@default_error_messages = {
      :empty            => "cannot be empty",
      :blank            => "cannot be blank",
      :invalid_date     => "is not a valid date",
      :invalid_time     => "is not a valid time",
      :invalid_datetime => "is not a valid datetime",
      :before           => "must be before %s",
      :on_or_before     => "must be on or before %s",
      :after            => "must be after %s",
      :on_or_after      => "must be on or after %s"
    }

    def initialize(configuration)
      defaults = { :on => :save, :type => :datetime, :allow_nil => false, :allow_blank => false }
      defaults.update(self.class.mapped_default_error_messages)
      @configuration = defaults.merge(configuration)
      @errors = []
    end
      
    # The main validation method which can be used directly or called through
    # the other specific type validation methods.      
    def call(record, attr_name, value)
      @errors = []
      return if (value.nil? && configuration[:allow_nil]) || (value.blank? && configuration[:allow_blank])

      @errors << configuration[:blank_message] and return if value.blank?
      
      begin
        unless time = record.class.parse_date_time(value, configuration[:type])
          @errors << configuration["invalid_#{configuration[:type]}_message".to_sym]
          return
        end
       
        validate_restrictions(record, attr_name, time)
      rescue Exception => e
        @errors << configuration["invalid_#{configuration[:type]}_message".to_sym]
      end
    end
    
   private
   
    # Validate value against the temporal restrictions. Restriction values 
    # maybe of mixed type, so they are evaluated as a common type, which may
    # require conversion. The type used is defined by validation type.
    def validate_restrictions(record, attr_name, value)
      restriction_methods = {:before => '<', :after => '>', :on_or_before => '<=', :on_or_after => '>='}
      
      type_cast_method = self.class.restriction_type_cast_method(configuration[:type])
      
      display = @@date_time_error_value_formats[configuration[:type]]
      
      value = value.send(type_cast_method)
      
      restriction_methods.each do |option, method|
        next unless restriction = configuration[option]
        begin
          compare = self.class.restriction_value(restriction, record, configuration[:type])
          
          next if compare.nil?
          
          compare = compare.send(type_cast_method)
          @errors << (configuration["#{option}_message".to_sym] % compare.strftime(display)) unless value.send(method, compare)
        rescue
          @errors << "restriction '#{option}' value was invalid" unless self.ignore_datetime_restriction_errors
        end
      end
    end
    
    def self.restriction_value(restriction, record, type)
      case restriction
        when Time, Date, DateTime
          restriction
        when Symbol
          restriction_value(record.send(restriction), record, type)
        when Proc
          restriction_value(restriction.call(record), record, type)
        else
         record.class.parse_date_time(restriction, type, false)
      end
    end
    
    def self.restriction_type_cast_method(type)
      case type
        when :time     then :to_dummy_time
        when :date     then :to_date
        when :datetime then :to_time
      end
    end
    # Map error message keys to *_message to merge with validation options
    def self.mapped_default_error_messages
      returning({}) do |messages|
        @@default_error_messages.each {|k, v| messages["#{k}_message".to_sym] = v }
      end
    end
    
  end
end
