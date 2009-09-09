module ValidatesTimeliness

  def self.enable_active_record_datetime_parser!
    ::ActiveRecord::Base.send(:include, ValidatesTimeliness::ActiveRecord::AttributeMethods)
  end

  module ActiveRecord

    # Overrides write method for date, time and datetime columns
    # to use plugin parser. Also adds mechanism to store value
    # before type cast.
    #
    module AttributeMethods

      def self.included(base)
        base.extend ClassMethods
        base.class_eval do
          alias_method_chain :read_attribute_before_type_cast, :timeliness
          class << self
            alias_method_chain :define_attribute_methods, :timeliness
          end
        end
      end

      def write_date_time_attribute(attr_name, value, type, time_zone_aware)
        @attributes_cache["_#{attr_name}_before_type_cast"] = value

        value = ValidatesTimeliness::Parser.parse(value, type)

        if value && type != :date
          value = value.to_time
          value = value.in_time_zone if time_zone_aware
        end

        write_attribute(attr_name.to_sym, value)
      end

      def read_attribute_before_type_cast_with_timeliness(attr_name)
        cached_attr = "_#{attr_name}_before_type_cast"
        return @attributes_cache[cached_attr] if @attributes_cache.has_key?(cached_attr)
        read_attribute_before_type_cast_without_timeliness(attr_name)
      end

      module ClassMethods

        def define_attribute_methods_with_timeliness
          return if generated_methods?
          timeliness_methods = []

          columns_hash.each do |name, column|
            if [:date, :time, :datetime].include?(column.type)
              time_zone_aware = create_time_zone_conversion_attribute?(name, column) rescue false

              define_method("#{name}=") do |value|
                write_date_time_attribute(name, value, column.type, time_zone_aware)
              end
              timeliness_methods << name
            end
          end

          define_attribute_methods_without_timeliness
          @generated_methods += timeliness_methods
        end

      end

    end

  end
end
