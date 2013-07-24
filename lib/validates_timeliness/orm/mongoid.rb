module ValidatesTimeliness
  module ORM
    module Mongoid
      extend ActiveSupport::Concern
      # You need define the fields before you define the validations.
      # It is best to use the plugin parser to avoid errors on a bad
      # field value in Mongoid. Parser will return nil rather than error.

      module ClassMethods
        public

        # Mongoid has no bulk attribute method definition hook. It defines
        # them with each field definition. So we likewise define them after
        # each validation is defined.
        #
        def timeliness_validation_for(attr_names, type)
          super
          attr_names.each { |attr_name| define_timeliness_write_method(attr_name) }
        end

        def timeliness_attribute_type(attr_name)
          {
            Date => :date,
            Time => :time,
            DateTime => :datetime
          }[fields[database_field_name(attr_name)].type] || :datetime
        end

        protected

        def timeliness_type_cast_code(attr_name, var_name)
          type = timeliness_attribute_type(attr_name)

          "#{var_name} = Timeliness::Parser.parse(value, :#{type})"
        end
      end

      def reload(*args)
        _clear_timeliness_cache
        super
      end
    end
  end
end

module Mongoid::Document
  include ValidatesTimeliness::AttributeMethods
  include ValidatesTimeliness::ORM::Mongoid
end
