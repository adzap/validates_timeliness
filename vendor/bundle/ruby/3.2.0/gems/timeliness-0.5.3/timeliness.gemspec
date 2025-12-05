# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "timeliness/version"

Gem::Specification.new do |s|

  github_url    = 'https://github.com/adzap/timeliness'

  s.name        = "timeliness"
  s.version     = Timeliness::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Adam Meehan"]
  s.email       = %q{adam.meehan@gmail.com}
  s.homepage    = %q{http://github.com/adzap/timeliness}
  s.summary     = %q{Date/time parsing for the control freak.}
  s.description = %q{Fast date/time parser with customisable formats, timezone and I18n support.}
  s.license     = "MIT"

  s.metadata = {
    "rubygems_mfa_required" => "true",
    "bug_tracker_uri" => "#{github_url}/issues",
    "changelog_uri"   => "#{github_url}/blob/master/CHANGELOG.rdoc",
    "source_code_uri" => "#{github_url}",
    "wiki_uri"        => "#{github_url}/wiki",
  }

  s.add_development_dependency 'activesupport', '>= 3.2'
  s.add_development_dependency 'tzinfo', '>= 0.3.31'
  s.add_development_dependency 'rspec', '~> 3.4'
  s.add_development_dependency 'timecop'
  s.add_development_dependency 'base64'
  s.add_development_dependency 'bigdecimal'
  s.add_development_dependency 'mutex_m'
  s.add_development_dependency 'i18n'

  s.files            = `git ls-files`.split("\n")
  s.files            = `git ls-files`.split("\n") - %w{ .gitignore .rspec Gemfile Gemfile.lock }
  s.extra_rdoc_files = ["README.rdoc", "CHANGELOG.rdoc"]
  s.require_paths    = ["lib"]
end
