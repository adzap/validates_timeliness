require 'validates_timeliness/base'
require 'validates_timeliness/attribute_methods'
require 'validates_timeliness/validations'

ActiveRecord::Base.send(:include, ValidatesTimeliness::Base)
ActiveRecord::Base.send(:include, ValidatesTimeliness::AttributeMethods)
ActiveRecord::Base.send(:include, ValidatesTimeliness::Validations)
