$:.unshift(File.dirname(__FILE__) + '/../lib')
$:.unshift(File.dirname(__FILE__))
$:.unshift(File.dirname(__FILE__) + '/resources')

ENV['RAILS_ENV'] = 'test'

require 'rubygems'
require 'spec'

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

require 'spec/rails'
require 'time_travel/time_travel'

ActiveRecord::Base.default_timezone = :utc
RAILS_VER = Rails::VERSION::STRING
puts "Using #{vendored ? 'vendored' : 'gem'} Rails version #{RAILS_VER} (ActiveRecord version #{ActiveRecord::VERSION::STRING})"

require 'validates_timeliness'

if RAILS_VER >= '2.1'
  Time.zone_default = ActiveSupport::TimeZone['UTC']
  ActiveRecord::Base.time_zone_aware_attributes = true
end


ActiveRecord::Migration.verbose = false
ActiveRecord::Base.establish_connection({:adapter => 'sqlite3', :database => ':memory:'})

# patches adapter in rails 2.0 which mistakenly made time attributes map to datetime column typs
if RAILS_VER < '2.1'
  ActiveRecord::ConnectionAdapters::SQLiteAdapter.class_eval do
    def native_database_types #:nodoc:
      {
        :primary_key => default_primary_key_type,
        :string      => { :name => "varchar", :limit => 255 },
        :text        => { :name => "text" },
        :integer     => { :name => "integer" },
        :float       => { :name => "float" },
        :decimal     => { :name => "decimal" },
        :datetime    => { :name => "datetime" },
        :timestamp   => { :name => "datetime" },
        :time        => { :name => "time" },
        :date        => { :name => "date" },
        :binary      => { :name => "blob" },
        :boolean     => { :name => "boolean" }
      }
    end
  end
end

require 'schema'
require 'person'
