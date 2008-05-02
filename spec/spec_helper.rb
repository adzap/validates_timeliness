$: << File.dirname(__FILE__) + '/../lib' << File.dirname(__FILE__)

require 'rubygems'
require 'spec'

if File.exists?(File.dirname(__FILE__) + '/../../../rails')
  $: << File.dirname(__FILE__) + '/../../../rails'
  require 'activerecord/lib/active_record'
  require 'activerecord/lib/active_record/version' 
  puts "Using vendor ActiveRecord version #{ActiveRecord::VERSION::STRING}"
else  
  require 'active_record'
  require 'active_record/version'
  puts "Using gem ActiveRecord version #{ActiveRecord::VERSION::STRING}"
end

require 'validates_timeliness'

conn = {
  :adapter  => 'sqlite3',
  :database  => ':memory:'
}

ActiveRecord::Base.establish_connection(conn)

require 'resources/schema'
require 'resources/person'
