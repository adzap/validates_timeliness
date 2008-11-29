require 'validates_timeliness/validations'
require 'validates_timeliness/formats'
require 'validates_timeliness/validate_timeliness_matcher' if ENV['RAILS_ENV'] == 'test'

require 'validates_timeliness/active_record/attribute_methods'
require 'validates_timeliness/active_record/multiparameter_attributes'
require 'validates_timeliness/action_view/instance_tag'

require 'validates_timeliness/core_ext/time'
require 'validates_timeliness/core_ext/date'
require 'validates_timeliness/core_ext/date_time'

ActiveRecord::Base.send(:include, ValidatesTimeliness::Validations)
ActiveRecord::Base.send(:include, ValidatesTimeliness::ActiveRecord::AttributeMethods)
ActiveRecord::Base.send(:include, ValidatesTimeliness::ActiveRecord::MultiparameterAttributes)
ActionView::Helpers::InstanceTag.send(:include, ValidatesTimeliness::ActionView::InstanceTag)

Time.send(:include, ValidatesTimeliness::CoreExtensions::Time)
Date.send(:include, ValidatesTimeliness::CoreExtensions::Date)
DateTime.send(:include, ValidatesTimeliness::CoreExtensions::DateTime)

ValidatesTimeliness::Formats.compile_format_expressions
