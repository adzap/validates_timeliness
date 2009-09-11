$:.unshift(File.dirname(__FILE__) + '/../lib')
$:.unshift(File.dirname(__FILE__))
$:.unshift(File.dirname(__FILE__) + '/resources')

RAILS_ENV = ENV['RAILS_ENV'] = 'test'

require 'rubygems'
require 'spec/autorun'

vendored_rails = File.dirname(__FILE__) + '/../../../../vendor/rails'

if vendored = File.exists?(vendored_rails)
  Dir.glob(vendored_rails + "/**/lib").each { |dir| $:.unshift dir }
else
  begin
   require 'ginger' 
  rescue LoadError
  end
  if ENV['VERSION']
    gem 'rails', ENV['VERSION']
  else
    gem 'rails'
  end
end

RAILS_ROOT = File.dirname(__FILE__)

require 'rails/version'
require 'active_record'
require 'active_record/version'
require 'action_controller'
require 'action_view'
require 'action_mailer'

require 'spec/rails'
require 'time_travel/time_travel'

ActiveRecord::Base.default_timezone = :utc
RAILS_VER = Rails::VERSION::STRING
puts "Using #{vendored ? 'vendored' : 'gem'} Rails version #{RAILS_VER} (ActiveRecord version #{ActiveRecord::VERSION::STRING})"

if RAILS_VER >= '2.1'
  Time.zone_default = ActiveSupport::TimeZone['UTC']
  ActiveRecord::Base.time_zone_aware_attributes = true
end

require 'validates_timeliness'
require 'validates_timeliness/matcher'

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.establish_connection({:adapter => 'sqlite3', :database => ':memory:'})

require 'sqlite_patch' if RAILS_VER < '2.1'

require 'schema'
require 'person'
