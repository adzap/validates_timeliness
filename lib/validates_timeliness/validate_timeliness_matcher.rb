module Spec
  module Rails
    module Matchers
      class ValidateTimeliness
        attr_reader :actual, :expected, :record, :options, :last_failure
   
        def initialize(attribute, options)
          @expected, @options = attribute, options
          @options.reverse_merge!(error_messages)
        end
        
        def matches?(record)
          @record = record
          type = options[:type]
          
          test_values = {
            :date     => {:pass => '2000-01-01', :fail => '2000-01-32'},
            :time     => {:pass => '12:00',      :fail => '25:00'},
            :datetime => {:pass => '2000-01-01 00:00:00', :fail => '2000-01-32 00:00:00'}
          }
          
          invalid_value = test_values[type][:fail]
          valid_value   = parse_and_cast(test_values[type][:pass])
          valid = error_matching(invalid_value, /#{options["invalid_#{type}_message".to_sym]}/) &&
              no_error_matching(valid_value, /#{options["invalid_#{type}_message".to_sym]}/)

          valid = test_option(:before, :-) if options[:before] && valid
          valid = test_option(:after, :+) if options[:after] && valid
          
          valid = test_option(:on_or_before, :+, :pre) if options[:on_or_before] && valid
          valid = test_option(:on_or_after, :-, :pre) if options[:on_or_after] && valid

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
        
        def test_option(option, modifier, modify_when=:post)
          boundary = parse_and_cast(options[option])
          
          valid_value   = modify_when == :post ? boundary.send(modifier, 1) : boundary
          invalid_value = modify_when == :post ? boundary : boundary.send(modifier, 1)
          
          message = options["#{option}_message".to_sym]
          error_matching(invalid_value, /#{message}/) && 
            no_error_matching(valid_value, /#{message}/)
        end
       
        def parse_and_cast(value)
          @conversion_method ||= case options[:type]
            when :time     then :to_dummy_time
            when :date     then :to_date
            when :datetime then :to_time
          end
          value = ActiveRecord::Base.parse_date_time(value, options[:type])
          value.send(@conversion_method)
        end
        
        def error_messages
          messages = ActiveRecord::Base.send(:timeliness_default_error_messages)
          messages = messages.inject({}) {|h, (k, v)| h[k] = v.sub(' %s', ''); h } 
          @options.reverse_merge!(messages)
        end
        
        def error_matching(value, match)
          record.send("#{expected}=", value)
          record.valid?
          errors = record.errors.on(expected)
          pass = case errors
            when String
              match === errors
            when Array
              errors.any? {|error| match === error }
            else
              false
          end
          @last_failure = "error matching #{match.inspect} when value is #{format_value(value)}" unless pass
          pass
        end
        
        def no_error_matching(value, match)        
          pass = !error_matching(value, match)
          @last_failure = "error matching #{match.inspect} when value is #{format_value(value)}" unless pass
          pass
        end
        
        def format_value(value)
          return value if value.is_a?(String)
          value.strftime(ActiveRecord::Errors.date_time_error_value_formats[options[:type]])
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
