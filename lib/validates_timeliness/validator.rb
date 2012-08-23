require 'active_model/validator'

module ValidatesTimeliness
  class Validator < ActiveModel::EachValidator
    include Conversion

    attr_reader :type

    RESTRICTIONS = {
      :is_at        => :==,
      :before       => :<,
      :after        => :>,
      :on_or_before => :<=,
      :on_or_after  => :>=,
    }.freeze

    DEFAULT_ERROR_VALUE_FORMATS = {
      :date => '%Y-%m-%d',
      :time => '%H:%M:%S',
      :datetime => '%Y-%m-%d %H:%M:%S'
    }.freeze

    RESTRICTION_ERROR_MESSAGE = "Error occurred validating %s for %s restriction:\n%s"

    def self.kind
      :timeliness
    end

    def initialize(options)
      @type = options.delete(:type) || :datetime
      @allow_nil, @allow_blank = options.delete(:allow_nil), options.delete(:allow_blank)

      if range = options.delete(:between)
        raise ArgumentError, ":between must be a Range or an Array" unless range.is_a?(Range) || range.is_a?(Array)
        options[:on_or_after], options[:on_or_before] = range.first, range.last
      end

      @restrictions_to_check = RESTRICTIONS.keys & options.keys
      super
    end

    def setup(model)
      if model.respond_to?(:timeliness_validated_attributes)
        model.timeliness_validated_attributes ||= []
        model.timeliness_validated_attributes |= @attributes
      end
    end

    def validate_each(record, attr_name, value)
      raw_value = attribute_raw_value(record, attr_name) || value
      return if (@allow_nil && raw_value.nil?) || (@allow_blank && raw_value.blank?)

      @timezone_aware = timezone_aware?(record, attr_name)
      value = parse(raw_value) if value.is_a?(String) || options[:format]
      value = type_cast_value(value, @type)

      add_error(record, attr_name, :"invalid_#{@type}") and return if value.blank?

      validate_restrictions(record, attr_name, value)
    end

    def validate_restrictions(record, attr_name, value)
      @restrictions_to_check.each do |restriction|
        begin
          restriction_value = type_cast_value(evaluate_option_value(options[restriction], record), @type)
          unless value.send(RESTRICTIONS[restriction], restriction_value)
            add_error(record, attr_name, restriction, restriction_value) and break
          end
        rescue => e
          unless ValidatesTimeliness.ignore_restriction_errors
            message = RESTRICTION_ERROR_MESSAGE % [ attr_name, restriction.inspect, e.message ]
            add_error(record, attr_name, message) and break
          end
        end
      end
    end

    def add_error(record, attr_name, message, value=nil)
      value = format_error_value(value) if value
      message_options = { :message => options[:"#{message}_message"], :restriction => value }
      record.errors.add(attr_name, message, message_options)
    end

    def format_error_value(value)
      format = I18n.t(@type, :default => DEFAULT_ERROR_VALUE_FORMATS[@type], :scope => 'validates_timeliness.error_value_formats')
      value.strftime(format)
    end

    def attribute_raw_value(record, attr_name)
      record.respond_to?(:_timeliness_raw_value_for) &&
        record._timeliness_raw_value_for(attr_name.to_s)
    end

    def timezone_aware?(record, attr_name)
      record.class.respond_to?(:timeliness_attribute_timezone_aware?) &&
        record.class.timeliness_attribute_timezone_aware?(attr_name)
    end

  end
end

# Compatibility with ActiveModel validates method which matches option keys to their validator class
ActiveModel::Validations::TimelinessValidator = ValidatesTimeliness::Validator
