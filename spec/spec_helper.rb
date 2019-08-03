require 'rspec'

require 'byebug'
require 'active_model'
require 'active_model/validations'
require 'active_record'
require 'action_view'
require 'timecop'

require 'validates_timeliness'
require 'validates_timeliness/orm/active_model'

require 'rails/railtie'

require 'support/test_model'
require 'support/model_helpers'
require 'support/config_helper'
require 'support/tag_matcher'

ValidatesTimeliness.setup do |c|
  c.extend_orms = [ :active_record ]
  c.enable_date_time_select_extension!
  c.enable_multiparameter_extension!
  c.default_timezone = :utc
end

Time.zone = 'Australia/Melbourne'

LOCALE_PATH = File.expand_path(File.dirname(__FILE__) + '/../lib/generators/validates_timeliness/templates/en.yml')
I18n.load_path.unshift(LOCALE_PATH)
I18n.available_locales = ['en', 'es']

# Extend TestModel as you would another ORM/ODM module
module TestModelShim
  extend ActiveSupport::Concern
  include ValidatesTimeliness::AttributeMethods
  include ValidatesTimeliness::ORM::ActiveModel

  module ClassMethods
    # Hook into native time zone handling check, if any
    def timeliness_attribute_timezone_aware?(attr_name)
      false
    end
  end
end

class Person
  include TestModel
  attribute :birth_date, :date
  attribute :birth_time, :time
  attribute :birth_datetime, :datetime

  define_attribute_methods model_attributes.keys
end

class PersonWithShim < Person
  include TestModelShim
end

ActiveRecord::Base.default_timezone = :utc
ActiveRecord::Base.time_zone_aware_attributes = true
ActiveRecord::Base.establish_connection({:adapter => 'sqlite3', :database => ':memory:'})
ActiveRecord::Base.time_zone_aware_types = [:datetime, :time]
ActiveRecord::Migration.verbose = false
ActiveRecord::Schema.define(:version => 1) do
  create_table :employees, :force => true do |t|
    t.string   :first_name
    t.string   :last_name
    t.date     :birth_date
    t.time     :birth_time
    t.datetime :birth_datetime
  end
end

class Employee < ActiveRecord::Base
  attr_accessor :redefined_birth_date_called
  validates_date :birth_date, :allow_nil => true
  validates_time :birth_time, :allow_nil => true
  validates_datetime :birth_datetime, :allow_nil => true

  def birth_date=(value)
    self.redefined_birth_date_called = true
    super
  end
end

RSpec.configure do |c|
  c.mock_with :rspec
  c.include(TagMatcher)
  c.include(ModelHelpers)
  c.include(ConfigHelper)
  c.before do
    reset_validation_setup_for(Person)
    reset_validation_setup_for(PersonWithShim)
  end

  c.filter_run_excluding :active_record => lambda {|version|
    !(::ActiveRecord::VERSION::STRING.to_s =~ /^#{version.to_s}/)
  }
end
