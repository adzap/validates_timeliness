$:.unshift(File.dirname(__FILE__) + '/../lib')
$:.unshift(File.dirname(__FILE__))

require 'rspec'
require 'rspec/autorun'

require 'active_model'
require 'active_model/validations'
require 'active_record'
require 'timecop'

require 'validates_timeliness'

ValidatesTimeliness.setup do |c|
  c.extend_classes = [ ActiveModel::Validations, ActiveRecord::Base ]
end

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

require 'model_helpers'

Rspec.configure do |c|
  c.mock_with :rspec
  c.before do
    Person.reset_callbacks(:validate)
    Person._validators.clear
  end
end
