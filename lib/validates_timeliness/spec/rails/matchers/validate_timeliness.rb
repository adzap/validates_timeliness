module Spec
  module Rails
    module Matchers
      class ValidateTimeliness
        cattr_accessor :test_values
   
        @@test_values = {
          :date     => {:pass => '2000-01-01', :fail => '2000-01-32'},
          :time     => {:pass => '12:00',      :fail => '25:00'},
          :datetime => {:pass => '2000-01-01 00:00:00', :fail => '2000-01-32 00:00:00'}
        }

        def initialize(attribute, options)
          @expected, @options = attribute, options
          @validator = ValidatesTimeliness::Validator.new(options)
          compile_error_messages
        end
        
        def compile_error_messages
          messages = validator.send(:error_messages)
          @messages = messages.inject({}) {|h, (k, v)| h[k] = v.gsub(/ (\%s|\{\{\w*\}\})/, ''); h }
        end

        def matches?(record)
          @record = record
          type = options[:type]
          
          invalid_value = @@test_values[type][:fail]
          valid_value   = parse_and_cast(@@test_values[type][:pass])
          valid = error_matching(invalid_value, /#{messages["invalid_#{type}".to_sym]}/) &&
              no_error_matching(valid_value, /#{messages["invalid_#{type}".to_sym]}/)

          valid = test_option(:before, :-) if options[:before] && valid
          valid = test_option(:after, :+) if options[:after] && valid
          
          valid = test_option(:on_or_before, :+, :modify_on => :invalid) if options[:on_or_before] && valid
          valid = test_option(:on_or_after, :-, :modify_on => :invalid) if options[:on_or_after] && valid

          return valid
        end
      
        def failure_message
          "expected model to validate #{options[:type]} attribute #{expected.inspect} with #{last_failure}"
        end
        
        def negative_failure_message
          "expected not to validate #{options[:type]} attribute #{expected.inspect}"
        end
        
        def description
          "have validated #{options[:type]} attribute #{expected.inspect}"
        end
        
       private
        attr_reader :actual, :expected, :record, :options, :messages, :last_failure, :validator
        
        def test_option(option, modifier, settings={})
          settings.reverse_merge!(:modify_on => :valid)
          boundary = parse_and_cast(options[option])
          
          valid_value, invalid_value = if settings[:modify_on] == :valid
            [ boundary.send(modifier, 1), boundary ]
          else
            [ boundary, boundary.send(modifier, 1) ]
          end
          
          message = messages[option]
          error_matching(invalid_value, /#{message}/) && 
            no_error_matching(valid_value, /#{message}/)
        end
       
        def parse_and_cast(value)
          value = validator.send(:restriction_value, value, record)
          validator.send(:type_cast_value, value)
        end

        def error_matching(value, match)
          record.send("#{expected}=", value)
          record.valid?
          errors = record.errors.on(expected)
          pass = [ errors ].flatten.any? {|error| match === error }
          @last_failure = "error matching #{match.inspect} when value is #{format_value(value)}" unless pass
          pass
        end
        
        def no_error_matching(value, match)
          pass = !error_matching(value, match)
          @last_failure = "no error matching #{match.inspect} when value is #{format_value(value)}" unless pass
          pass
        end
        
        def format_value(value)
          return value if value.is_a?(String)
          value.strftime(ValidatesTimeliness.error_value_formats[options[:type]])
        end
      end

      def validate_date(attribute, options={})
        options[:type] = :date
        validate_timeliness_of(attribute, options)
      end

      def validate_time(attribute, options={})
        options[:type] = :time
        validate_timeliness_of(attribute, options)
      end

      def validate_datetime(attribute, options={})
        options[:type] = :datetime
        validate_timeliness_of(attribute, options)
      end

      private

      def validate_timeliness_of(attribute, options={})
        ValidateTimeliness.new(attribute, options)
      end

    end
  end
end
