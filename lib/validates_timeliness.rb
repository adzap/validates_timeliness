require 'validates_timeliness/base'
require 'validates_timeliness/attribute_methods'
require 'validates_timeliness/validations'
require 'validates_timeliness/instance_tag'
#require 'validates_timeliness/validate_timeliness_matcher'

ActiveRecord::Base.send(:include, ValidatesTimeliness::Base)
ActiveRecord::Base.send(:include, ValidatesTimeliness::AttributeMethods)
ActiveRecord::Base.send(:include, ValidatesTimeliness::Validations)
ActionView::Helpers::InstanceTag.send(:include, ValidatesTimeliness::InstanceTag)
