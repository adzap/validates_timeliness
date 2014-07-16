source 'http://rubygems.org'

gemspec

gem 'rails', '~> 3.2.6'
gem 'timecop'
gem 'ruby-debug', :platforms => [:ruby_18, :jruby]
gem 'debugger', :platforms => [:ruby_19]
gem 'appraisal'
gem 'sqlite3'
gem 'nokogiri'

group :mongoid do
  gem 'mongoid', '~> 2.3.0'
  gem 'bson_ext'
  gem 'system_timer', :platforms => [:ruby_18]
end

group :active_record do
  gem 'sqlite3-ruby', :require => 'sqlite3'
end
