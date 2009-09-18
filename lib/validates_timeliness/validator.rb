module ValidatesTimeliness

  class Validator
    cattr_accessor :ignore_restriction_errors
    self.ignore_restriction_errors = false

    RESTRICTION_METHODS = {
      :equal_to     => :==,
      :before       => :<, 
      :after        => :>, 
      :on_or_before => :<=,
      :on_or_after  => :>=,
      :between      => lambda {|v, r| (r.first..r.last).include?(v) } 
    }

    VALID_OPTIONS = [
      :on, :if, :unless, :allow_nil, :empty, :allow_blank,
      :with_time, :with_date, :ignore_usec, :format,
      :invalid_time_message, :invalid_date_message, :invalid_datetime_message
    ] + RESTRICTION_METHODS.keys.map {|option| [option, "#{option}_message".to_sym] }.flatten

    attr_reader :configuration, :type

    def initialize(configuration)
      defaults = { :on => :save, :type => :datetime, :allow_nil => false, :allow_blank => false, :ignore_usec => false }
      @configuration = defaults.merge(configuration)
      @type = @configuration.delete(:type)
      validate_options(@configuration)
    end
      
    def call(record, attr_name, value)
      raw_value = raw_value(record, attr_name) || value

      if value.is_a?(String) || configuration[:format]
        value = ValidatesTimeliness::Parser.parse(raw_value, type, :strict => false, :format => configuration[:format])
      end

      return if (raw_value.nil? && configuration[:allow_nil]) || (raw_value.blank? && configuration[:allow_blank])

      return add_error(record, attr_name, :blank) if raw_value.blank?
      return add_error(record, attr_name, "invalid_#{type}".to_sym) if value.nil?

      validate_restrictions(record, attr_name, value)
    end

    def error_messages
      @error_messages ||= self.class.default_error_messages.merge(custom_error_messages)
    end

   private

    def raw_value(record, attr_name)
      record.send("#{attr_name}_before_type_cast") rescue nil
    end
   
    def validate_restrictions(record, attr_name, value)
      if configuration[:with_time] || configuration[:with_date]
        value = combine_date_and_time(value, record)
      end

      value = self.class.type_cast_value(value, implied_type, configuration[:ignore_usec])

      return if value.nil?

      RESTRICTION_METHODS.each do |option, method|
        next unless restriction = configuration[option]
        begin
          restriction = self.class.evaluate_option_value(restriction, implied_type, record)
          next if restriction.nil?
          restriction = self.class.type_cast_value(restriction, implied_type, configuration[:ignore_usec])

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
        message = I18n.t('activerecord.errors.messages')[option]
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
        custom = custom_error_messages[message]
        record.errors.add(attr_name, message, { :default => custom }.merge(interpolate || {}))
      else
        message = error_messages[message] if message.is_a?(Symbol)
        message = message % interpolate
        record.errors.add(attr_name, message)
      end
    end

    def custom_error_messages
      @custom_error_messages ||= configuration.inject({}) {|msgs, (k, v)|
        if md = /(.*)_message$/.match(k.to_s) 
          msgs[md[1].to_sym] = v
        end
        msgs
      }
    end

    def combine_date_and_time(value, record)
      if type == :date
        date = value
        time = configuration[:with_time]
      else
        date = configuration[:with_date]
        time = value
      end
      date, time = self.class.evaluate_option_value(date, :date, record), self.class.evaluate_option_value(time, :time, record)
      return if date.nil? || time.nil?
      ValidatesTimeliness::Parser.make_time([date.year, date.month, date.day, time.hour, time.min, time.sec, time.usec])
    end

    def validate_options(options)
      invalid_for_type = ([:time, :date, :datetime] - [type]).map {|k| "invalid_#{k}_message".to_sym }
      invalid_for_type << :with_date unless type == :time
      invalid_for_type << :with_time unless type == :date
      options.assert_valid_keys(VALID_OPTIONS - invalid_for_type)
    end

    def implied_type
      @implied_type ||= configuration[:with_date] || configuration[:with_time] ? :datetime : type 
    end

    # class methods
    class << self

      def default_error_messages
        if defined?(I18n)
          I18n.t('activerecord.errors.messages')
        else
          ::ActiveRecord::Errors.default_error_messages
        end
      end

      def error_value_formats
        if defined?(I18n)
          I18n.t('validates_timeliness.error_value_formats')
        else
          @@error_value_formats
        end
      end

      def error_value_formats=(formats)
        @@error_value_formats = formats
      end

      def evaluate_option_value(value, type, record)
        case value
        when Time, Date
          value
        when Symbol
          evaluate_option_value(record.send(value), type, record)
        when Proc
          result = value.arity > 0 ? value.call(record) : value.call
          evaluate_option_value(result, type, record)
        when Array
          value.map {|r| evaluate_option_value(r, type, record) }.sort
        when Range
          evaluate_option_value([value.first, value.last], type, record)
        else
          ValidatesTimeliness::Parser.parse(value, type, :strict => false)
        end
      end

      def type_cast_value(value, type, ignore_usec=false)
        if value.is_a?(Array)
          value.map {|v| type_cast_value(v, type, ignore_usec) }
        else
          value = case type
          when :time
            dummy_time(value)
          when :date
            value.to_date
          when :datetime
            if value.is_a?(Time) || value.is_a?(DateTime)
              value.to_time
            else
              value.to_time(ValidatesTimeliness.default_timezone)
            end
          else
            nil
          end
          if ignore_usec && value.is_a?(Time)
            ValidatesTimeliness::Parser.make_time(Array(value).reverse[4..9])
          else
            value
          end
        end
      end

      def dummy_time(value)
        if value.is_a?(Time) || value.is_a?(DateTime)
          time = [value.hour, value.min, value.sec]
        else
          time = [0,0,0]
        end
        dummy_date = ValidatesTimeliness::Formats.dummy_date_for_time_type
        ValidatesTimeliness::Parser.make_time(dummy_date + time)
      end

    end

  end
end
