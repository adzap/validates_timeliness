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
      @allow_nil, @allow_blank = options.delete(:allow_nil), options.delete(:allow_blank)
      @type = options.delete(:type) || :datetime
      @check_restrictions = RESTRICTIONS.keys & options.keys

      if range = options.delete(:between)
        raise ArgumentError, ":between must be a Range or an Array" unless range.is_a?(Range) || range.is_a?(Array)
        options[:on_or_after], options[:on_or_before] = range.first, range.last
      end
      super
    end

    def check_validity!
    end

    def validate_each(record, attr_name, value)
      raw_value = attribute_raw_value(record, attr_name) || value
      return if (@allow_nil && raw_value.nil?) || (@allow_blank && raw_value.blank?)

      value = type_cast(value)

      return record.errors.add(attr_name, :"invalid_#{@type}") if value.blank?

      @check_restrictions.each do |restriction|
        begin
          restriction_value = type_cast(evaluate_option_value(options[restriction], record))
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

    def attribute_raw_value(record, attr_name)
      record._timeliness_raw_value_for(attr_name)
    end

    def type_cast(value)
      type_cast_value(value, @type)
    end

    def format_error_value(value)
      format = I18n.t(@type, :scope => 'validates_timeliness.error_value_formats')
      value.strftime(format)
    end
  end
end

# Compatibility with ActiveModel validates method which matches option keys to their validator class
TimelinessValidator = ValidatesTimeliness::Validator
