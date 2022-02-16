# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "validates_timeliness/version"

Gem::Specification.new do |s|

  github_url    = 'https://github.com/adzap/validates_timeliness'

  s.name        = "validates_timeliness"
  s.version     = ValidatesTimeliness::VERSION
  s.authors     = ["Adam Meehan"]
  s.summary     = %q{Date and time validation plugin for Rails which allows custom formats}
  s.description = %q{Adds validation methods to ActiveModel for validating dates and times. Works with multiple ORMS.}
  s.email       = %q{adam.meehan@gmail.com}
  s.homepage    = github_url
  s.license     = "MIT"

  s.require_paths    = ["lib"]
  s.files            = `git ls-files`.split("\n") - %w{ .gitignore .rspec Gemfile Gemfile.lock autotest/discover.rb Appraisals } - Dir['gemsfiles/*']
  s.test_files       = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.extra_rdoc_files = ["README.md", "CHANGELOG.md", "LICENSE"]

  s.metadata = {
    "bug_tracker_uri" => "#{github_url}/issues",
    "changelog_uri"   => "#{github_url}/blob/master/CHANGELOG.md",
    "source_code_uri" => "#{github_url}",
    "wiki_uri"        => "#{github_url}/wiki",
  }

  s.add_runtime_dependency("activemodel", [">= 6.0.0", "< 7"])
  s.add_runtime_dependency("timeliness", [">= 0.3.10", "< 1"])
end
