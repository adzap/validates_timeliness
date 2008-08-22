$:.unshift(File.dirname(__FILE__) + '/../lib')
$:.unshift(File.dirname(__FILE__))

ENV['RAILS_ENV'] = 'test'

require 'rubygems'
require 'spec'
require 'spec/interop/test'

vendored_rails = File.dirname(__FILE__) + '/../../../../vendor/rails'

if vendored = File.exists?(vendored_rails)
  Dir.glob(vendored_rails + "/**/lib").each { |dir| $:.unshift dir }
else
  gem 'rails', "=#{ENV['VERSION']}" if ENV['VERSION']
end

require 'rails/version'
require 'active_record'
require 'active_record/version'
require 'action_controller'
require 'action_controller/test_process'
require 'action_view'

require 'rspec-rails/rspec-rails'
require 'time_travel/time_travel'
require 'validates_timeliness'

RAILS_VER = Rails::VERSION::STRING

puts "Using #{vendored ? 'vendored' : 'gem'} Rails version #{RAILS_VER} (ActiveRecord version #{ActiveRecord::VERSION::STRING})"

ActiveRecord::Base.default_timezone = :utc

if RAILS_VER >= '2.1'
  Time.zone_default = TimeZone['UTC']
  ActiveRecord::Base.time_zone_aware_attributes = true
end

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.establish_connection({:adapter => 'sqlite3', :database => ':memory:'})

require 'resources/schema'
require 'resources/person'
