module Spec
  module Rails
    module Matchers
      class ValidateTimeliness
        def initialize(attribute, options)
          @expected, @options = attribute, options
        end

        def matches?(record)
          @record = record    

          valid = error_matching('2008-02-30', /valid/) &&
              error_matching('2008-01-01 25:00:00', /valid/) &&
              no_error_matching('2008-01-01 12:12:12', /valid/)
          return false unless valid
          
          if after = options[:after]
            valid = error_matching(after, /after/) &&
              no_error_matching(after + 1, /after/)
          end
          return false unless valid
          
          if before = options[:before]
            valid = error_matching(before, /before/) &&
              no_error_matching(before - 1, /before/)              
          end
          return false unless valid
        
          if on_or_after = options[:on_or_after]
            valid = error_matching(on_or_after -1, /after/) &&
              no_error_matching(on_or_after, /after/)              
          end
          return false unless valid
          
          if on_or_before = options[:on_or_before]
            valid = error_matching(on_or_before + 1, /before/) &&
              no_error_matching(on_or_before, /before/)              
          end
          return false unless valid
          
          return true
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
        attr_reader :actual, :expected, :record, :options, :last_failure
        
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
      end
      
      def validate_timeliness_of(attribute, options={})
        ValidateTimeliness.new(attribute, options)
      end   
    end
  end  
end
