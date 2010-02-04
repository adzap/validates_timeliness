require 'rubygems'
require 'rake/gempackagetask'
require 'rubygems/specification'
require 'date'
require 'spec/rake/spectask'
require 'lib/validates_timeliness/version'

GEM = "validates_timeliness"
GEM_VERSION = ValidatesTimeliness::VERSION

spec = Gem::Specification.new do |s|
  s.name = GEM
  s.version = GEM_VERSION
  s.platform = Gem::Platform::RUBY
  s.rubyforge_project = "validatestime"
  s.has_rdoc = true
  s.extra_rdoc_files = ["README.rdoc", "LICENSE", "TODO", "CHANGELOG"]
  s.summary = "Date and time validation plugin for Rails 2.x which allows custom formats"
  s.description = s.summary
  s.author = "Adam Meehan"
  s.email = "adam.meehan@gmail.com"
  s.homepage = "http://github.com/adzap/validates_timeliness"

  s.require_path = 'lib'
  s.autorequire = GEM
  s.files = %w(LICENSE README.rdoc Rakefile TODO CHANGELOG) + Dir.glob("{lib,spec}/**/*")
end

task :default => :spec

desc "Run specs"
Spec::Rake::SpecTask.new do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
  t.spec_opts = %w(--color)
end


Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end

desc "install the gem locally"
task :install => [:package] do
  sh %{sudo gem install pkg/#{GEM}-#{GEM_VERSION}}
end

desc "create a gemspec file"
task :make_spec do
  File.open("#{GEM}.gemspec", "w") do |file|
    file.puts spec.to_ruby
  end
end
