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
          
          conversion_method = case type
            when :time     then :to_dummy_time
            when :date     then :to_date
            when :datetime then :to_time
          end
          
          test_values = {
            :date     => {:pass => '2000-01-01', :fail => '2000-01-32'},
            :time     => {:pass => '12:00',      :fail => '25:00'},
            :datetime => {:pass => '2000-01-01 00:00:00', :fail => '2000-01-32 00:00:00'}
          }

          valid = error_matching(test_values[type][:fail], /#{options["invalid_#{type}_message".to_sym]}/) &&
              no_error_matching(test_values[type][:pass], /#{options["invalid_#{type}_message".to_sym]}/)
                    
          if valid && options[:after]
            after = parse(options[:after], type).send(conversion_method)
            valid = error_matching(after, /#{options[:after_message]}/) &&
              no_error_matching(after + 1, /#{options[:after_message]}/)
          end
          
          if valid && options[:before]
            before = parse(options[:before], type).send(conversion_method)
            valid = error_matching(before, /#{options[:before_message]}/) &&
              no_error_matching(before - 1, /#{options[:before_message]}/)
          end
        
          if valid && options[:on_or_after]
            on_or_after = parse(options[:on_or_after], type).send(conversion_method)
            valid = error_matching(on_or_after -1, /#{options[:on_or_after_message]}/) &&
              no_error_matching(on_or_after, /#{options[:on_or_after_message]}/)
          end
          
          if valid && options[:on_or_before]
            on_or_before = parse(options[:on_or_before], type).send(conversion_method)
            valid = error_matching(on_or_before + 1, /#{options[:on_or_before_message]}/) &&
              no_error_matching(on_or_before, /#{options[:on_or_before_message]}/)
          end
          
          return valid
        end
      
        def failure_message
          "expected model to validate timeliness of #{expected.inspect} with #{last_failure}"
        end
        
        def negative_failure_message
          "expected not to validate timeliness of #{expected.inspect}"
        end
        
        def description
          "have validated timeliness of #{expected.inspect}"
        end
        
       private
       
        def parse(value, type)
          ActiveRecord::Base.parse_date_time(value, type)
        end
        
        def error_messages
          messages = ActiveRecord::Base.send(:timeliness_default_error_messages)
          messages = messages.inject({}) {|h, (k, v)| h[k] = v.sub('%s', ''); h } 
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
          @last_failure = "value #{value} to have error matching #{match.inspect}" unless pass
          pass
        end
        
        def no_error_matching(value, match)        
          pass = !error_matching(value, match)
          @last_failure = "value #{value} to not have error matching #{match.inspect}" unless pass
          pass
        end
        
        def format_value(value)
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
