require 'validates_timeliness/formats'
require 'validates_timeliness/parser'
require 'validates_timeliness/validator'
require 'validates_timeliness/validation_methods'
require 'validates_timeliness/spec/rails/matchers/validate_timeliness' if ENV['RAILS_ENV'] == 'test'

require 'validates_timeliness/active_record/attribute_methods'
require 'validates_timeliness/active_record/multiparameter_attributes'
require 'validates_timeliness/action_view/instance_tag'

require 'validates_timeliness/core_ext/time'
require 'validates_timeliness/core_ext/date'
require 'validates_timeliness/core_ext/date_time'

module ValidatesTimeliness
  
  mattr_accessor :default_timezone
  self.default_timezone = :utc 

  mattr_accessor :use_time_zones
  self.use_time_zones = false

  LOCALE_PATH = File.expand_path(File.dirname(__FILE__) + '/validates_timeliness/locale/en.yml')

  class << self

    def enable_datetime_select_extension!
      enable_datetime_select_invalid_value_extension!
      enable_multiparameter_attributes_extension!
    end

    def load_error_messages
      if defined?(I18n)
        I18n.load_path += [ LOCALE_PATH ]
        I18n.reload!
      else
        defaults = YAML::load(IO.read(LOCALE_PATH))['en']
        errors = defaults['activerecord']['errors']['messages'].inject({}) {|h,(k,v)| h[k.to_sym] = v.gsub(/\{\{\w*\}\}/, '%s');h }
        ::ActiveRecord::Errors.default_error_messages.update(errors)

        ValidatesTimeliness::Validator.error_value_formats = defaults['validates_timeliness']['error_value_formats'].symbolize_keys
      end
    end
    
    def setup_for_rails
      self.default_timezone = ::ActiveRecord::Base.default_timezone
      self.use_time_zones = ::ActiveRecord::Base.time_zone_aware_attributes rescue false
      load_error_messages
    end
  end
end

ValidatesTimeliness.setup_for_rails
