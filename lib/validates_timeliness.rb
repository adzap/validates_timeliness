require 'validates_timeliness/formats'
require 'validates_timeliness/validator'
require 'validates_timeliness/validation_methods'
require 'validates_timeliness/spec/rails/matchers/validate_timeliness' if ENV['RAILS_ENV'] == 'test'

require 'validates_timeliness/active_record/attribute_methods'
require 'validates_timeliness/active_record/multiparameter_attributes'
require 'validates_timeliness/action_view/instance_tag'

require 'validates_timeliness/core_ext/time'
require 'validates_timeliness/core_ext/date'
require 'validates_timeliness/core_ext/date_time'

ActiveRecord::Base.send(:include, ValidatesTimeliness::ValidationMethods)
ActiveRecord::Base.send(:include, ValidatesTimeliness::ActiveRecord::AttributeMethods)
ActiveRecord::Base.send(:include, ValidatesTimeliness::ActiveRecord::MultiparameterAttributes)
ActionView::Helpers::InstanceTag.send(:include, ValidatesTimeliness::ActionView::InstanceTag)

Time.send(:include, ValidatesTimeliness::CoreExtensions::Time)
Date.send(:include, ValidatesTimeliness::CoreExtensions::Date)
DateTime.send(:include, ValidatesTimeliness::CoreExtensions::DateTime)

ValidatesTimeliness::Formats.compile_format_expressions

module ValidatesTimeliness
  
  mattr_accessor :ignore_restriction_errors
  mattr_accessor :error_value_formats
  mattr_accessor :default_error_messages
  
  @@ignore_restriction_errors = false
    
  @@error_value_formats = {
    :time     => '%H:%M:%S',
    :date     => '%Y-%m-%d',
    :datetime => '%Y-%m-%d %H:%M:%S'
  }      
    
  @@default_error_messages = {
    :empty            => "cannot be empty",
    :blank            => "cannot be blank",
    :invalid_date     => "is not a valid date",
    :invalid_time     => "is not a valid time",
    :invalid_datetime => "is not a valid datetime",
    :before           => "must be before %s",
    :on_or_before     => "must be on or before %s",
    :after            => "must be after %s",
    :on_or_after      => "must be on or after %s"
  }

end
