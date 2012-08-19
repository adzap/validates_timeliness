module ValidatesTimeliness
  module ORM
    module ActiveRecord
      extend ActiveSupport::Concern

      module ClassMethods
        public

        def timeliness_attribute_timezone_aware?(attr_name)
          create_time_zone_conversion_attribute?(attr_name, timeliness_column_for_attribute(attr_name))
        end

        def timeliness_attribute_type(attr_name)
          timeliness_column_for_attribute(attr_name).type
        end

        def timeliness_column_for_attribute(attr_name)
          columns_hash.fetch(attr_name.to_s) do |attr_name|
            validation_type = _validators[attr_name.to_sym].find {|v| v.kind == :timeliness }.type
            ::ActiveRecord::ConnectionAdapters::Column.new(attr_name, nil, validation_type.to_s)
          end
        end

        def define_attribute_methods
          super.tap do |attribute_methods_generated|
            define_timeliness_methods true
          end
        end

        protected

        def timeliness_type_cast_code(attr_name, var_name)
          type = timeliness_attribute_type(attr_name)

          method_body = super
          method_body << "\n#{var_name} = #{var_name}.to_date if #{var_name}" if type == :date
          method_body
        end
      end

      def reload(*args)
        _clear_timeliness_cache
        super
      end

    end
  end
end

class ActiveRecord::Base
  include ValidatesTimeliness::AttributeMethods
  include ValidatesTimeliness::ORM::ActiveRecord
end
