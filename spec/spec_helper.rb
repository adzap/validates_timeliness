$: << File.dirname(__FILE__) + '/../lib' << File.dirname(__FILE__)

require 'rubygems'
require 'spec'

if File.exists?(File.dirname(__FILE__) + '/../../../../vendor/rails')
  $:.unshift File.dirname(__FILE__) + '/../../../../vendor/rails'
  require 'activesupport/lib/active_support'
  require 'activerecord/lib/active_record' 
  require 'activerecord/lib/active_record/version'
  require 'railties/lib/rails/version'
  vendored = true
else  
  gem 'rails', "=#{ENV['VERSION']}" if ENV['VERSION']
  require 'rails/version'
  require 'active_record'
  require 'active_record/version'
  vendored = false
end

puts "Using #{vendored ? 'vendored' : 'gem'} Rails version #{Rails::VERSION::STRING} (ActiveRecord version #{ActiveRecord::VERSION::STRING})"

RAILS_VER = Rails::VERSION::STRING

ActiveRecord::Base.default_timezone = :utc

if RAILS_VER >= '2.1'
  Time.zone_default = TimeZone['UTC']
  ActiveRecord::Base.time_zone_aware_attributes = true
end

require 'validates_timeliness'

ActiveRecord::Base.establish_connection({:adapter => 'sqlite3', :database => ':memory:'})

require 'resources/schema'
require 'resources/person'
