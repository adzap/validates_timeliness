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

    def self.kind
      :timeliness
    end

    def initialize(options)
      @type = options.delete(:type) || :datetime
      @allow_nil, @allow_blank = options.delete(:allow_nil), options.delete(:allow_blank)
      @restrictions_to_check = RESTRICTIONS.keys & options.keys

      if range = options.delete(:between)
        raise ArgumentError, ":between must be a Range or an Array" unless range.is_a?(Range) || range.is_a?(Array)
        options[:on_or_after], options[:on_or_before] = range.first, range.last
      end
      super
    end

    def validate_each(record, attr_name, value)
      raw_value = record._timeliness_raw_value_for(attr_name) || value
      return if (@allow_nil && raw_value.nil?) || (@allow_blank && raw_value.blank?)

      @timezone_aware = record.class.timeliness_attribute_timezone_aware?(attr_name)
      value = parse(value) if value.is_a?(String)
      value = type_cast_value(value, @type)

      return record.errors.add(attr_name, :"invalid_#{@type}") if value.blank?

      @restrictions_to_check.each do |restriction|
        begin
          restriction_value = type_cast_value(evaluate_option_value(options[restriction], record), @type)

          unless value.send(RESTRICTIONS[restriction], restriction_value)
            return record.errors.add(attr_name, restriction, :message => options[:"#{restriction}_message"], :restriction => format_error_value(restriction_value))
          end
        rescue => e
          unless ValidatesTimeliness.ignore_restriction_errors
            record.errors[attr_name] = "Error occurred validating #{attr_name} for #{restriction.inspect} restriction:\n#{e.message}" 
          end
        end
      end
    end

    def format_error_value(value)
      format = I18n.t(@type, :scope => 'validates_timeliness.error_value_formats')
      value.strftime(format)
    end

  end
end

# Compatibility with ActiveModel validates method which matches option keys to their validator class
TimelinessValidator = ValidatesTimeliness::Validator
