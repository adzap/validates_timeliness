module ValidatesTimeliness

  class Validator
    cattr_accessor :ignore_restriction_errors
    cattr_accessor :error_value_formats

    self.ignore_restriction_errors = false
    self.error_value_formats = {
      :time     => '%H:%M:%S',
      :date     => '%Y-%m-%d',
      :datetime => '%Y-%m-%d %H:%M:%S'
    }      

    attr_reader :configuration, :type

    def initialize(configuration)
      defaults = { :on => :save, :type => :datetime, :allow_nil => false, :allow_blank => false }
      @configuration = defaults.merge(configuration)
      @type = @configuration.delete(:type)
    end
      
    # The main validation method which can be used directly or called through
    # the other specific type validation methods.      
    def call(record, attr_name)
      value     = record.send(attr_name)
      raw_value = raw_value(record, attr_name)

      return if (raw_value.nil? && configuration[:allow_nil]) || (raw_value.blank? && configuration[:allow_blank])

      add_error(record, attr_name, :blank) and return if raw_value.blank?
       
      add_error(record, attr_name, "invalid_#{type}".to_sym) and return unless value

      validate_restrictions(record, attr_name, value)
    end
    
   private

    def raw_value(record, attr_name)
      record.send("#{attr_name}_before_type_cast")
    end
   
    def validate_restrictions(record, attr_name, value)
      restriction_methods = {:before => '<', :after => '>', :on_or_before => '<=', :on_or_after => '>='}
      
      display = self.class.error_value_formats[type]
      
      value = type_cast_value(value)
      
      restriction_methods.each do |option, method|
        next unless restriction = configuration[option]
        begin
          compare = restriction_value(restriction, record)
          next if compare.nil?
          compare = type_cast_value(compare)

          unless value.send(method, compare)
            add_error(record, attr_name, option, :restriction => compare.strftime(display))
          end
        rescue
          unless self.class.ignore_restriction_errors
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
        # use i18n support in AR for message or use custom message passed to validation method
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
    
    def restriction_value(restriction, record)
      case restriction
        when Time, Date, DateTime
          restriction
        when Symbol
          restriction_value(record.send(restriction), record)
        when Proc
          restriction_value(restriction.call(record), record)
        else
         record.class.parse_date_time(restriction, type, false)
      end
    end
    
    def type_cast_value(value)
      case type
        when :time
          value.to_dummy_time
        when :date
          value.to_date
        when :datetime
          if value.is_a?(DateTime) || value.is_a?(Time)
            value.to_time
          else
            value.to_time(ValidatesTimelines.default_timezone)
          end
        else
          nil
      end
    end

  end
end
