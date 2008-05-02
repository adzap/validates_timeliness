$: << File.dirname(__FILE__) + '/../lib' << File.dirname(__FILE__)

require 'rubygems'
require 'spec'
require 'active_support'
require 'active_record'

require 'validates_timeliness'

conn = {
  :adapter  => 'sqlite3',  
  :database  => ':memory:'
}

ActiveRecord::Base.establish_connection(conn)

require 'resources/schema'
require 'resources/person'
