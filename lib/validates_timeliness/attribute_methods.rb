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
            time = read_attribute('#{attr_name}')
            unless time.acts_like?(:time)
              time = time.to_time(:local) rescue nil
            end
            @attributes_cache['#{attr_name}'] = time.acts_like?(:time) ? time.in_time_zone : time
          end
        EOV
        evaluate_attribute_method attr_name, method_body
      end
      
      def define_write_method_for_time_zone_conversion(attr_name)
        method_body = <<-EOV
          def #{attr_name}=(time)
            if time
              time = time.in_time_zone if time.acts_like?(:time)              
            end
            write_attribute(:#{attr_name}, time)
          end
        EOV
        evaluate_attribute_method attr_name, method_body, "#{attr_name}="
      end      
    end  
      
  end
end
