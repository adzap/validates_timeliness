module ValidatesTimeliness
  module ORM
    module ActiveModel
      extend ActiveSupport::Concern

      module ClassMethods
        public

        def define_attribute_methods(*attr_names)
          super.tap { define_timeliness_methods}
        end

        def undefine_attribute_methods
          super.tap { undefine_timeliness_attribute_methods }
        end
      end
      
    end
  end
end
