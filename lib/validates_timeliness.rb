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
  
  @@ignore_restriction_errors = false
    
  @@error_value_formats = {
    :time     => '%H:%M:%S',
    :date     => '%Y-%m-%d',
    :datetime => '%Y-%m-%d %H:%M:%S'
  }      
    
  def self.load_error_messages
    path = File.expand_path(File.dirname(__FILE__) + '/validates_timeliness/locale/en.yml')
    if Rails::VERSION::STRING < '2.2'
      messages = YAML::load(IO.read(path))
      errors = messages['en']['activerecord']['errors']['messages'].inject({}) {|h,(k,v)| h[k.to_sym] = v.gsub(/\{\{\w*\}\}/, '%s');h }
      ::ActiveRecord::Errors.default_error_messages.update(errors)
    else
      I18n.load_path += [ path ]
    end
  end

  def self.default_error_messages
    if Rails::VERSION::STRING < '2.2'
      ::ActiveRecord::Errors.default_error_messages
    else
      I18n.translate('activerecord.errors.messages')
    end
  end
end

ValidatesTimeliness.load_error_messages
