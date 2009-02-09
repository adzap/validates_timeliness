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

    RESTRICTION_METHODS = {
      :before       => :<, 
      :after        => :>, 
      :on_or_before => :<=,
      :on_or_after  => :>=,
      :between      => lambda {|v, r| (r.first..r.last).include?(v) } 
    }

    VALID_OPTIONS = [
      :on, :allow_nil, :empty, :allow_blank, :blank, :invalid_time_message, :invalid_date_message, :invalid_datetime_message
    ] + RESTRICTION_METHODS.keys.map {|option| [option, "#{option}_message".to_sym] }.flatten

    attr_reader :configuration, :type

    def initialize(configuration)
      defaults = { :on => :save, :type => :datetime, :allow_nil => false, :allow_blank => false }
      @configuration = defaults.merge(configuration)
      @type = @configuration.delete(:type)
      validate_options(@configuration)
    end
      
    def call(record, attr_name, value)
      value     = record.class.parse_date_time(value, type, false) if value.is_a?(String)
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
      value = type_cast_value(value)
      
      RESTRICTION_METHODS.each do |option, method|
        next unless restriction = configuration[option]
        begin
          restriction = restriction_value(restriction, record)
          next if restriction.nil?
          restriction = type_cast_value(restriction)

          unless evaluate_restriction(restriction, value, method)
            add_error(record, attr_name, option, interpolation_values(option, restriction))
          end
        rescue
          unless self.class.ignore_restriction_errors
            add_error(record, attr_name, "restriction '#{option}' value was invalid")
          end
        end
      end
    end

    def interpolation_values(option, restriction)
      format = self.class.error_value_formats[type]
      restriction = [restriction] unless restriction.is_a?(Array)

      if defined?(I18n)
        message = custom_error_messages[option] || I18n.translate('activerecord.errors.messages')[option]
        subs = message.scan(/\{\{([^\}]*)\}\}/)
        interpolations = {}
        subs.each_with_index {|s, i| interpolations[s[0].to_sym] = restriction[i].strftime(format) }
        interpolations
      else
        restriction.map {|r| r.strftime(format) }
      end
    end

    def evaluate_restriction(restriction, value, comparator)
      return true if restriction.nil?

      case comparator
      when Symbol
        value.send(comparator, restriction)
      when Proc
        comparator.call(value, restriction)
      end
    end
    
    def add_error(record, attr_name, message, interpolate=nil)
      if defined?(I18n)
        # use i18n support in AR for message or use custom message passed to validation method
        custom = custom_error_messages[message]
        record.errors.add(attr_name, custom || message, interpolate || {})
      else
        message = error_messages[message] if message.is_a?(Symbol)
        message = message % interpolate
        record.errors.add(attr_name, message)
      end
    end

    def error_messages
      @error_messages ||= ValidatesTimeliness.default_error_messages.merge(custom_error_messages)
    end
    
    def custom_error_messages
      @custom_error_messages ||= configuration.inject({}) {|msgs, (k, v)|
        if md = /(.*)_message$/.match(k.to_s) 
          msgs[md[1].to_sym] = v
        end
        msgs
      }
    end
    
    def restriction_value(restriction, record)
      case restriction
      when Time, Date, DateTime
        restriction
      when Symbol
        restriction_value(record.send(restriction), record)
      when Proc
        restriction_value(restriction.call(record), record)
      when Array
        restriction.map {|r| restriction_value(r, record) }.sort
      when Range
        restriction_value([restriction.first, restriction.last], record)
      else
       record.class.parse_date_time(restriction, type, false)
      end
    end
    
    def type_cast_value(value)
      if value.is_a?(Array)
        value.map {|v| type_cast_value(v) }
      else 
        case type
        when :time
          value.to_dummy_time
        when :date
          value.to_date
        when :datetime
          if value.is_a?(DateTime) || value.is_a?(Time)
            value.to_time
          else
            value.to_time(ValidatesTimeliness.default_timezone)
          end
        else
          nil
        end
      end
    end

    def validate_options(options)
      invalid_types = [:time, :date, :datetime]
      invalid_types.delete(@type)
      valid_options = VALID_OPTIONS.reject {|option| invalid_types.include?("#{option}_message".to_sym) }
      options.assert_valid_keys(valid_options)
    end

  end
end
