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

module ValidatesTimeliness
  
  mattr_accessor :default_timezone

  self.default_timezone = :utc 

  LOCALE_PATH = File.expand_path(File.dirname(__FILE__) + '/validates_timeliness/locale/en.yml')

  class << self

    def load_error_messages_with_i18n
      I18n.load_path += [ LOCALE_PATH ]
      I18n.reload!
    end

    def load_error_messages_without_i18n
      messages = YAML::load(IO.read(LOCALE_PATH))
      errors = messages['en']['activerecord']['errors']['messages'].inject({}) {|h,(k,v)| h[k.to_sym] = v.gsub(/\{\{\w*\}\}/, '%s');h }
      ::ActiveRecord::Errors.default_error_messages.update(errors)
    end
    
    def default_error_messages
      if Rails::VERSION::STRING < '2.2'
        ::ActiveRecord::Errors.default_error_messages
      else
        I18n.translate('activerecord.errors.messages')
      end
    end

    def setup_for_rails_2_0
      load_error_messages_without_i18n
    end
    alias :setup_for_rails_2_1 :setup_for_rails_2_0

    def setup_for_rails_2_2
      load_error_messages_with_i18n
    end
    alias :setup_for_rails_2_3 :setup_for_rails_2_2

    def setup_for_rails
      major, minor = Rails::VERSION::MAJOR, Rails::VERSION::MINOR
      self.default_timezone = ::ActiveRecord::Base.default_timezone
      self.send("setup_for_rails_#{major}_#{minor}")
    rescue
      puts "Rails version #{major}.#{minor}.x not explicitly supported by validates_timeliness plugin. Setting up for Rails 2.2, but you may encounter some problems."
      setup_for_rails_2_2
    end
  end
end

ValidatesTimeliness.setup_for_rails
