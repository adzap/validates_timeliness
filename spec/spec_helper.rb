$: << File.dirname(__FILE__) + '/../lib' << File.dirname(__FILE__)

require 'rubygems'
require 'spec'

if File.exists?(File.dirname(__FILE__) + '/../../../../vendor/rails')
  $: << File.dirname(__FILE__) + '/../../../../vendor/rails'
  require 'activesupport/lib/active_support'
  require 'activerecord/lib/active_record'  
  require 'railties/lib/rails/version'  
  
  puts "Using vendored ActiveRecord version #{ActiveRecord::VERSION::STRING}"
else  
  require 'active_record'
  require 'active_record/version'
  require 'rails/version'
  
  puts "Using gem ActiveRecord version #{ActiveRecord::VERSION::STRING}"
end

require 'validates_timeliness'

ActiveRecord::Base.establish_connection({:adapter => 'sqlite3', :database => ':memory:'})

require 'resources/schema'
require 'resources/person'
