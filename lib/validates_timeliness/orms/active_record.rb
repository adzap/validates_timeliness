class ActiveRecord::Base
  include ValidatesTimeliness::HelperMethods
  include ValidatesTimeliness::AttributeMethods

  def self.define_attribute_methods
    super
    # Define write method and before_type_cast method
    define_timeliness_methods(true)
  end

  def self.timeliness_attribute_timezone_aware?(attr_name)
    create_time_zone_conversion_attribute?(attr_name, columns_hash[attr_name])
  end
end
