require 'time'

module TimeTravel
  module TimeExtensions
  
    def self.included(base)
      base.extend(ClassMethods)
      base.class_eval do
        class << self
          alias_method :immutable_now, :now
          alias_method :now, :mutable_now
        end
      end
      base.now = nil
    end
  
    module ClassMethods

      @@now = nil

      def now=(time)
        time = Time.parse(time) if time.instance_of?(String)
        @@now = time
      end

      def mutable_now #:nodoc:
        @@now || immutable_now
      end
    
    end
  
  end
end
