# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{validates_timeliness}
  s.version = "2.3.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Adam Meehan"]
  s.autorequire = %q{validates_timeliness}
  s.date = %q{2010-03-19}
  s.description = %q{Date and time validation plugin for Rails 2.x which allows custom formats}
  s.email = %q{adam.meehan@gmail.com}
  s.extra_rdoc_files = ["README.rdoc", "LICENSE", "TODO", "CHANGELOG"]
  s.files = ["LICENSE", "README.rdoc", "Rakefile", "TODO", "CHANGELOG", "lib/validates_timeliness", "lib/validates_timeliness/action_view", "lib/validates_timeliness/action_view/instance_tag.rb", "lib/validates_timeliness/active_record", "lib/validates_timeliness/active_record/attribute_methods.rb", "lib/validates_timeliness/active_record/multiparameter_attributes.rb", "lib/validates_timeliness/formats.rb", "lib/validates_timeliness/locale", "lib/validates_timeliness/locale/en.yml", "lib/validates_timeliness/matcher.rb", "lib/validates_timeliness/parser.rb", "lib/validates_timeliness/spec", "lib/validates_timeliness/spec/rails", "lib/validates_timeliness/spec/rails/matchers", "lib/validates_timeliness/spec/rails/matchers/validate_timeliness.rb", "lib/validates_timeliness/validation_methods.rb", "lib/validates_timeliness/validator.rb", "lib/validates_timeliness/version.rb", "lib/validates_timeliness.rb", "spec/action_view", "spec/action_view/instance_tag_spec.rb", "spec/active_record", "spec/active_record/attribute_methods_spec.rb", "spec/active_record/multiparameter_attributes_spec.rb", "spec/formats_spec.rb", "spec/ginger_scenarios.rb", "spec/parser_spec.rb", "spec/resources", "spec/resources/application.rb", "spec/resources/person.rb", "spec/resources/schema.rb", "spec/resources/sqlite_patch.rb", "spec/spec", "spec/spec/rails", "spec/spec/rails/matchers", "spec/spec/rails/matchers/validate_timeliness_spec.rb", "spec/spec_helper.rb", "spec/time_travel", "spec/time_travel/MIT-LICENSE", "spec/time_travel/time_extensions.rb", "spec/time_travel/time_travel.rb", "spec/validator_spec.rb"]
  s.homepage = %q{http://github.com/adzap/validates_timeliness}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{validatestime}
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Date and time validation plugin for Rails 2.x which allows custom formats}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
