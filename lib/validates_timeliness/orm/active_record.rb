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

        if ::ActiveModel.version >= Gem::Version.new('4.2')
          def timeliness_column_for_attribute(attr_name)
            columns_hash.fetch(attr_name.to_s) do |key|
              validation_type = _validators[key.to_sym].find {|v| v.kind == :timeliness }.type.to_s
              ::ActiveRecord::ConnectionAdapters::Column.new(key, nil, lookup_cast_type(validation_type), validation_type)
            end
          end
          
          def lookup_cast_type(sql_type)
            case sql_type
            when 'datetime' then ::ActiveRecord::Type::DateTime.new
            when 'date' then ::ActiveRecord::Type::Date.new
            when 'time' then ::ActiveRecord::Type::Time.new
            end
          end
        else
          def timeliness_column_for_attribute(attr_name)
            columns_hash.fetch(attr_name.to_s) do |key|
              validation_type = _validators[key.to_sym].find {|v| v.kind == :timeliness }.type.to_s
              ::ActiveRecord::ConnectionAdapters::Column.new(key, nil, validation_type)
            end
          end
        end

        def define_attribute_methods
          super.tap { 
            generated_timeliness_methods.synchronize do
              return if @timeliness_methods_generated
              define_timeliness_methods true
              @timeliness_methods_generated = true
            end
          }
        end

        def undefine_attribute_methods
          super.tap { 
            generated_timeliness_methods.synchronize do
              return unless @timeliness_methods_generated
              undefine_timeliness_attribute_methods 
              @timeliness_methods_generated = false
            end
          }
        end
        # Override to overwrite methods in ActiveRecord attribute method module because in AR 4+
        # there is curious code which calls the method directly from the generated methods module
        # via bind inside method_missing. This means our method in the formerly custom timeliness
        # methods module was never reached.
        def generated_timeliness_methods
          generated_attribute_methods
        end
      end

      def write_timeliness_attribute(attr_name, value)
        @timeliness_cache ||= {}
        @timeliness_cache[attr_name] = value

        if ValidatesTimeliness.use_plugin_parser
          type = self.class.timeliness_attribute_type(attr_name)
          timezone = :current if self.class.timeliness_attribute_timezone_aware?(attr_name)
          value = Timeliness::Parser.parse(value, type, :zone => timezone)
          value = value.to_date if value && type == :date
        end

        write_attribute(attr_name, value)
      end
      
      def read_timeliness_attribute_before_type_cast(attr_name)
        @timeliness_cache && @timeliness_cache[attr_name] || read_attribute_before_type_cast(attr_name)
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
