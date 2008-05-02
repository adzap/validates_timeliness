module ValidatesTimeliness
  module AttributeMethods
    
    def self.included(base)
      base.extend ClassMethods
    end
    
    module ClassMethods
      def define_read_method_for_time_zone_conversion(attr_name)
        method_body = <<-EOV          
          def #{attr_name}(reload = false)
            cached = @attributes_cache['#{attr_name}']
            return cached if cached && !reload
            time = read_attribute_before_type_cast('#{attr_name}')
            if time && time.acts_like?(:time)
              # Rails 2.0.x compatibility check
              time = time.respond_to?(:in_time_zone) ? time.in_time_zone : time
            elsif time
              # checks date is valid
              time.to_date rescue time = nil
              time = time.to_time(:local) if time              
            end
            @attributes_cache['#{attr_name}'] = time
          end
        EOV
        evaluate_attribute_method attr_name, method_body
      end
      
      # TODO rails 2.0 time casting better with timezone
      def define_write_method_for_time_zone_conversion(attr_name)
        method_body = <<-EOV
          def #{attr_name}=(time)            
            if time && time.respond_to?(:in_time_zone)
              time = time.in_time_zone
            elsif time && time.acts_like?(:time)              
              # Rails 2.0.x compatibility
              time = @@default_timezone == :utc ? time.to_time : time.to_time
            end
            write_attribute(:#{attr_name}, time)
          end
        EOV
        evaluate_attribute_method attr_name, method_body, "#{attr_name}="
      end      
    end  
      
  end
end
