require 'active_model'
require 'active_model/validator'

module ValidatesTimeliness
  class Validator < ActiveModel::EachValidator
    attr_reader :type, :attributes, :converter

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

    RESERVED_OPTIONS = RESTRICTIONS.keys + RESTRICTIONS.keys.map { |option| :"#{option}_message" }

    def self.kind
      :timeliness
    end

    def initialize(options)
      @type = options.delete(:type) || :datetime
      @allow_nil, @allow_blank = options.delete(:allow_nil), options.delete(:allow_blank)

      if range = options.delete(:between)
        raise ArgumentError, ":between must be a Range or an Array" unless range.is_a?(Range) || range.is_a?(Array)
        options[:on_or_after] = range.first
        if range.is_a?(Range) && range.exclude_end?
          options[:before] = range.last
        else
          options[:on_or_before] = range.last
        end
      end

      @restrictions_to_check = RESTRICTIONS.keys & options.keys

      super

      setup_timeliness_validated_attributes(options[:class]) if options[:class]
    end

    def setup_timeliness_validated_attributes(model)
      if model.respond_to?(:timeliness_validated_attributes)
        model.timeliness_validated_attributes ||= []
        model.timeliness_validated_attributes |= attributes
      end
    end

    def validate_each(record, attr_name, value)
      raw_value = attribute_raw_value(record, attr_name) || value
      return if (@allow_nil && raw_value.nil?) || (@allow_blank && raw_value.blank?)

      @converter = initialize_converter(record, attr_name)

      value = @converter.parse(raw_value) if value.is_a?(String) || options[:format]
      value = @converter.type_cast_value(value)

      add_error(record, attr_name, :"invalid_#{@type}") and return if value.blank?

      validate_restrictions(record, attr_name, value)
    end

    def validate_restrictions(record, attr_name, value)
      @restrictions_to_check.each do |restriction|
        begin
          restriction_value = @converter.type_cast_value(@converter.evaluate(options[restriction], record))
          unless value.send(RESTRICTIONS[restriction], restriction_value)
            add_error(record, attr_name, restriction, value: value, restriction_value: restriction_value) and break
          end
        rescue => e
          unless ValidatesTimeliness.ignore_restriction_errors
            message = RESTRICTION_ERROR_MESSAGE % [ attr_name, restriction.inspect, e.message ]
            add_error(record, attr_name, message) and break
          end
        end
      end
    end

    def add_error(record, attr_name, message, restriction_value: nil, value: nil)
      error_options = options.except(*RESERVED_OPTIONS).merge!(
        restriction: format_error_value(restriction_value),
        value: value
      )

      message_text = options[:"#{message}_message"]
      error_options[:message] = message_text if message_text.present?

      record.errors.add(attr_name, message, **error_options)
    end

    def format_error_value(value)
      return unless value
      format = I18n.t(@type, default: DEFAULT_ERROR_VALUE_FORMATS[@type], scope: 'validates_timeliness.error_value_formats')
      value.strftime(format)
    end

    def attribute_raw_value(record, attr_name)
      if record.respond_to?(:read_timeliness_attribute_before_type_cast)
        record.read_timeliness_attribute_before_type_cast(attr_name.to_s)
      end
    end

    def time_zone_aware?(record, attr_name)
      record.class.respond_to?(:skip_time_zone_conversion_for_attributes) &&
        !record.class.skip_time_zone_conversion_for_attributes.include?(attr_name.to_sym)
    end

    def initialize_converter(record, attr_name)
      ValidatesTimeliness::Converter.new(
        type: @type,
        time_zone_aware: time_zone_aware?(record, attr_name),
        format: options[:format],
        ignore_usec: options[:ignore_usec]
      )
    end

  end
end

# Compatibility with ActiveModel validates method which matches option keys to their validator class
ActiveModel::Validations::TimelinessValidator = ValidatesTimeliness::Validator
