# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "validates_timeliness/version"

Gem::Specification.new do |s|
  s.name        = "jc-validates_timeliness"
  s.version     = ValidatesTimeliness::VERSION
  s.authors     = ["Adam Meehan", "John Carney"]
  s.summary     = %q{Date and time validation plugin for Rails which allows custom formats}
  s.description = %q{Adds validation methods to ActiveModel for validating dates and times. Works with multiple ORMS.}
  s.email       = %q{adam.meehan@gmail.com}
  s.homepage    = %q{http://github.com/johncarney/validates_timeliness}

  s.require_paths    = ["lib"]
  s.files            = `git ls-files`.split("\n") - %w{ .gitignore .rspec Gemfile Gemfile.lock autotest/discover.rb Appraisals .travis.yml .coveralls.yml } - Dir['gemfiles/*']
  s.test_files       = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.extra_rdoc_files = ["CHANGELOG.rdoc", "LICENSE"]

  s.add_runtime_dependency(%q<timeliness>, ["~> 0.3.7"])

  s.add_development_dependency "coveralls"
  s.add_development_dependency "rspec", "~> 3.0"
  s.add_development_dependency "rspec-rails", "~> 3.0"
  s.add_development_dependency "rspec-collection_matchers"
end
