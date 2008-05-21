# For Rails 2.0.2:
#   This module adds method to create reader method for Time attributes
#   to allow for invalid date checking. If date is invalid then returns nil for
#   time value.
#
# For Rails >= 2.1  
#   This module overrides these AR methods to allow a time value passed to a column 
#   write method to be stored as is and only convert to a time on read.
#   This differs from the current AR behvaviour where the value is converted
#   on write.
#
#   This allows the before_type_cast method for the column to return the actual 
#   value passed to it, treating time columns like all other column types.
module ValidatesTimeliness
  module AttributeMethods
    
    def self.included(base)
      if Rails::VERSION::STRING <= '2.0.2'
        base.extend ClassMethods::Old
      else
        base.extend ClassMethods::New
      end
    end
    
    module ClassMethods
      # Rails > 2.0.2
      module New
        # Store time value as is including as a string. Only convert on read
        def define_write_method_for_time_zone_conversion(attr_name)
          method_body = <<-EOV
            def #{attr_name}=(time)
              if time.acts_like?(:time)
                time = time.in_time_zone rescue time            
              end
              write_attribute(:#{attr_name}, time)
            end
          EOV
          evaluate_attribute_method attr_name, method_body, "#{attr_name}="
        end
      end # New
    
      # Rails <= 2.0.2
      module Old
        # Copied from AR and inserted Time class check to time attribute
        def define_attribute_methods
          return if generated_methods?
          columns_hash.each do |name, column|
            unless instance_method_already_implemented?(name)
              if self.serialized_attributes[name]
                define_read_method_for_serialized_attribute(name)
              elsif column.klass == Time        
                define_read_method_for_time_attribute(name.to_sym)
              else
                define_read_method(name.to_sym, name, column)
              end
            end

            unless instance_method_already_implemented?("#{name}=")
              define_write_method(name.to_sym)
            end

            unless instance_method_already_implemented?("#{name}?")
              define_question_method(name)
            end
          end
        end

        # defines time attribute reader and does conversion strict
        def define_read_method_for_time_attribute(attr_name)
          method_body = <<-EOV          
          def #{attr_name}(reload = false)
            cached = @attributes_cache['#{attr_name}']
            return cached if cached && !reload
            time = read_attribute_before_type_cast('#{attr_name}')
            time = strict_time_type_cast(time)
            @attributes_cache['#{attr_name}'] = time
          end
          EOV
          evaluate_attribute_method attr_name, method_body
        end
      end # Old

    end # ClassMethods    
  end
end
