$: << File.dirname(__FILE__) + '/../lib' << File.dirname(__FILE__)

require 'rubygems'
require 'spec'

if File.exists?(File.dirname(__FILE__) + '/../../../rails')
  require 'activerecord/lib/active_record'
  require 'activerecord/lib/active_record/version' 
else  
  require 'active_record'
  require 'active_record/version'
end

require 'validates_timeliness'

conn = {
  :adapter  => 'sqlite3',  
  :database  => ':memory:'
}

ActiveRecord::Base.establish_connection(conn)

require 'resources/schema'
require 'resources/person'
