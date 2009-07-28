module ValidatesTimeliness

  def self.enable_multiparameter_attributes_extension!
    ::ActiveRecord::Base.send(:include, ValidatesTimeliness::ActiveRecord::MultiparameterAttributes)
  end

  module ActiveRecord

    class << self

      def time_array_to_string(values, type)
        values.collect! {|v| v.to_s }

        case type
        when :date
          extract_date_from_multiparameter_attributes(values)
        when :time
          extract_time_from_multiparameter_attributes(values)
        when :datetime
          extract_date_from_multiparameter_attributes(values) + " " + extract_time_from_multiparameter_attributes(values)
        end
      end

      def extract_date_from_multiparameter_attributes(values)
        year = ValidatesTimeliness::Formats.unambiguous_year(values[0].rjust(2, "0"))
        [year, *values.slice(1, 2).map { |s| s.rjust(2, "0") }].join("-")
      end

      def extract_time_from_multiparameter_attributes(values)
        values[3..5].map { |s| s.rjust(2, "0") }.join(":")
      end

    end

    module MultiparameterAttributes
      
      def self.included(base)
        base.alias_method_chain :execute_callstack_for_multiparameter_attributes, :timeliness
      end    

      # Assign dates and times as formatted strings to force the use of the plugin parser
      # and store a before_type_cast value for attribute
      def execute_callstack_for_multiparameter_attributes_with_timeliness(callstack)
        errors = []
        callstack.each do |name, values|
          column = column_for_attribute(name)
          if column && [:date, :time, :datetime].include?(column.type)
            begin
              callstack.delete(name)
              if values.empty?
                send("#{name}=", nil)
              else
                value = ValidatesTimeliness::ActiveRecord.time_array_to_string(values, column.type)
                send("#{name}=", value)
              end
            rescue => ex
              errors << ::ActiveRecord::AttributeAssignmentError.new("error on assignment #{values.inspect} to #{name}", ex, name)
            end
          end
        end
        unless errors.empty?
          raise ::ActiveRecord::MultiparameterAssignmentErrors.new(errors), "#{errors.size} error(s) on assignment of multiparameter attributes"
        end
        execute_callstack_for_multiparameter_attributes_without_timeliness(callstack)
      end
      
    end

  end
end
