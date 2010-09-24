class ActiveRecord::Base
  include ValidatesTimeliness::HelperMethods
  include ValidatesTimeliness::AttributeMethods

  class << self
    def define_attribute_methods
      super
      # Define write method and before_type_cast method
      define_timeliness_methods(true)
    end

    def timeliness_attribute_timezone_aware?(attr_name)
      create_time_zone_conversion_attribute?(attr_name, columns_hash[attr_name])
    end

    def timeliness_attribute_type(attr_name)
      columns_hash[attr_name.to_s].type
    end
  end
end
