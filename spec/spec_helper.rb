$:.unshift(File.dirname(__FILE__) + '/../lib')
$:.unshift(File.dirname(__FILE__))

require 'rspec'
require 'rspec/autorun'

require 'active_model'
require 'active_model/validations'
# require 'active_record'
# require 'action_controller'
# require 'action_view'
# require 'action_mailer'
# require 'rspec/rails'

require 'timecop'
require 'model_helpers'

require 'validates_timeliness'

Time.zone = 'Australia/Melbourne'

LOCALE_PATH = File.expand_path(File.dirname(__FILE__) + '/../lib/validates_timeliness/locale/en.yml')
I18n.load_path.unshift(LOCALE_PATH)

class Person
  include ActiveModel::Validations
  extend  ActiveModel::Translation

  attr_accessor :birth_date, :birth_time, :birth_datetime

  def initialize(attributes = {})
    attributes.each do |key, value|
      send "#{key}=", value
    end
  end
end

Rspec.configure do |c|
  c.mock_with :rspec
  c.before do
    Person.reset_callbacks(:validate)
    Person._validators.clear
  end
end
