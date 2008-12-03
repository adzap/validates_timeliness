module ValidatesTimeliness

  # Adds ActiveRecord validation methods for date, time and datetime validation.
  # The validity of values can be restricted to be before or after certain dates
  # or times.
  class Validator
    attr_reader :configuration, :type, :messages

    def initialize(configuration)
      defaults = { :on => :save, :type => :datetime, :allow_nil => false, :allow_blank => false }
      @configuration = defaults.merge(configuration)
      @type = @configuration.delete(:type)
    end
      
    # The main validation method which can be used directly or called through
    # the other specific type validation methods.      
    def call(record, attr_name, value)
      return if (value.nil? && configuration[:allow_nil]) || (value.blank? && configuration[:allow_blank])

      add_error(record, attr_name, :blank) and return if value.blank?
      
      time = record.class.parse_date_time(value, type)
      unless time
        add_error(record, attr_name, "invalid_#{type}".to_sym) and return
      end
      validate_restrictions(record, attr_name, time)
    end
    
   private
   
    # Validate value against the temporal restrictions. Restriction values 
    # maybe of mixed type, so they are evaluated as a common type, which may
    # require conversion. The type used is defined by validation type.
    def validate_restrictions(record, attr_name, value)
      restriction_methods = {:before => '<', :after => '>', :on_or_before => '<=', :on_or_after => '>='}
      
      type_cast_method = self.class.restriction_type_cast_method(type)
      
      display = ValidatesTimeliness.error_value_formats[type]
      
      value = value.send(type_cast_method)
      
      restriction_methods.each do |option, method|
        next unless restriction = configuration[option]
        begin
          compare = self.class.restriction_value(restriction, record, type)
          next if compare.nil?
          compare = compare.send(type_cast_method)

          unless value.send(method, compare)
            add_error(record, attr_name, option, :restriction => compare.strftime(display))
          end
        rescue
          unless ValidatesTimeliness.ignore_restriction_errors
            add_error(record, attr_name, "restriction '#{option}' value was invalid")
          end
        end
      end
    end
    
    def add_error(record, attr_name, message, interpolate={})
      if Rails::VERSION::STRING < '2.2'
        message = error_messages[message] if message.is_a?(Symbol)
        message = message % interpolate.values unless interpolate.empty?
        record.errors.add(attr_name, message)
      else
        custom = custom_error_messages[message]
        record.errors.add(attr_name, custom || message, interpolate)
      end
    end

    def error_messages
      return @error_messages if defined?(@error_messages)
      @error_messages = ValidatesTimeliness.default_error_messages.merge(custom_error_messages)
    end
    
    def custom_error_messages
      return @custom_error_messages if defined?(@custom_error_messages)
      @custom_error_messages = configuration.inject({}) {|h, (k, v)| h[$1.to_sym] = v if k.to_s =~ /(.*)_message$/;h }
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
  
  end
end
