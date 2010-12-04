require 'rubygems'
require 'rake/rdoctask'
require 'rake/gempackagetask'
require 'rubygems/specification'
require 'rspec/core/rake_task'
require 'lib/validates_timeliness/version'

GEM_NAME = "validates_timeliness"
GEM_VERSION = ValidatesTimeliness::VERSION

spec = Gem::Specification.new do |s|
  s.name = GEM_NAME
  s.version = GEM_VERSION
  s.platform = Gem::Platform::RUBY
  s.rubyforge_project = "validates_timeliness"
  s.has_rdoc = true
  s.extra_rdoc_files = ["README.rdoc", "CHANGELOG.rdoc", "LICENSE"]
  s.summary = %q{Date and time validation plugin for Rails which allows custom formats}
  s.description = s.summary
  s.author = "Adam Meehan"
  s.email = "adam.meehan@gmail.com"
  s.homepage = "http://github.com/adzap/validates_timeliness"
  s.require_path = 'lib'
  s.files = %w(validates_timeliness.gemspec LICENSE CHANGELOG.rdoc README.rdoc Rakefile) + Dir.glob("{lib,spec}/**/*")
  s.add_runtime_dependency 'timeliness', '~> 0.3.2'
end

desc 'Default: run specs.'
task :default => :spec

desc "Run specs"
RSpec::Core::RakeTask.new do |t|
  t.pattern = "./spec/**/*_spec.rb" # don't need this, it's default.
end

desc "Generate code coverage"
RSpec::Core::RakeTask.new(:coverage) do |t|
  t.rcov = true
  t.rcov_opts = ['--exclude', 'spec']
end

desc 'Generate documentation for plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'ValidatesTimeliness'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end

desc "Install the gem locally"
task :install => [:package] do
  sh %{gem install pkg/#{GEM_NAME}-#{GEM_VERSION}}
end

desc "Create a gemspec file"
task :make_spec do
  File.open("#{GEM_NAME}.gemspec", "w") do |file|
    file.puts spec.to_ruby
  end
end
