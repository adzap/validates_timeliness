$:.unshift(File.dirname(__FILE__) + '/../lib')
$:.unshift(File.dirname(__FILE__))

require 'rspec'
require 'rspec/autorun'

require 'active_model'
require 'active_model/validations'
require 'active_record'
require 'action_view'
require 'timecop'
require 'rspec_tag_matchers'
require 'model_helpers'

require 'validates_timeliness'
require 'test_model'

ValidatesTimeliness.setup do |c|
  c.extend_orms = [ :active_record ]
  c.enable_date_time_select_extension!
  c.enable_multiparameter_extension!
end

Time.zone = 'Australia/Melbourne'

LOCALE_PATH = File.expand_path(File.dirname(__FILE__) + '/../lib/generators/validates_timeliness/templates/en.yml')
I18n.load_path.unshift(LOCALE_PATH)

# Extend TestModel as you would another ORM/ODM module
module TestModel
  include ValidatesTimeliness::HelperMethods
  include ValidatesTimeliness::AttributeMethods

  def self.included(base)
    base.extend HookMethods
  end

  module HookMethods
    # Hook method for attribute method generation
    def define_attribute_methods(attr_names)
      super
      define_timeliness_methods
    end

    # Hook into native time zone handling check, if any
    def timeliness_attribute_timezone_aware?(attr_name)
      false
    end
  end
end

class Person
  include TestModel
  self.model_attributes = :birth_date, :birth_time, :birth_datetime
  validates_date :birth_date
  validates_time :birth_time
  validates_datetime :birth_datetime
  define_attribute_methods model_attributes
end

ActiveRecord::Base.establish_connection({:adapter => 'sqlite3', :database => ':memory:'})
ActiveRecord::Migration.verbose = false
ActiveRecord::Schema.define(:version => 1) do
  create_table :employees, :force => true do |t|
    t.string   :first_name
    t.string   :last_name
    t.datetime :birth_date
    t.datetime :birth_time
    t.datetime :birth_datetime
  end
end

class Employee < ActiveRecord::Base
  validates_date :birth_date
  validates_time :birth_time
  validates_datetime :birth_datetime
  define_attribute_methods
end

Rspec.configure do |c|
  c.mock_with :rspec
  c.include(RspecTagMatchers)
  c.before do
    Person.reset_callbacks(:validate)
    Person.timeliness_validated_attributes = {}
    Person._validators.clear
    Employee.reset_callbacks(:validate)
    Employee.timeliness_validated_attributes = {}
    Employee._validators.clear
  end
end
