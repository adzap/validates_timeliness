require 'active_support'
require 'active_support/time'
require 'active_support/core_ext/object'
require 'timecop'
require 'timeliness'
require 'timeliness/core_ext'

module TimelinessHelpers
  def parser
    Timeliness::Parser
  end

  def definitions
    Timeliness::Definitions
  end

  def parse(value, type=nil, **args)
    Timeliness::Parser.parse(value, type, **args)
  end

  def current_date(options={})
    Timeliness::Parser.send(:current_date, options)
  end

  def should_parse(value, type=nil, **args)
    expect(Timeliness::Parser.parse(value, type, **args)).not_to be_nil
  end

  def should_not_parse(value, type=nil, **args)
    expect(Timeliness::Parser.parse(value, type, **args)).to be_nil
  end
end

I18n.available_locales = ['en', 'es']

RSpec.configure do |c|
  c.mock_with :rspec
  c.include TimelinessHelpers

  c.after do
    Timeliness.configuration = Timeliness::Configuration.new
  end
end
