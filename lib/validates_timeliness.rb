require 'date'
require 'active_support/concern'
require 'active_support/core_ext/module'
require 'active_support/core_ext/hash/except'
require 'active_support/core_ext/string/conversions'
require 'active_support/core_ext/date/acts_like'
require 'active_support/core_ext/date/conversions'
require 'active_support/core_ext/time/acts_like'
require 'active_support/core_ext/time/conversions'
require 'active_support/core_ext/date_time/acts_like'
require 'active_support/core_ext/date_time/conversions'
require 'timeliness'

Timeliness.module_eval do
  class << self
    alias :dummy_date_for_time_type :date_for_time_type
    alias :dummy_date_for_time_type= :date_for_time_type=
    alias :remove_us_formats :use_euro_formats
  end
end

module ValidatesTimeliness
  autoload :VERSION, 'validates_timeliness/version'

  class << self
    delegate :default_timezone, :default_timezone=, :dummy_date_for_time_type, :dummy_date_for_time_type=, :to => Timeliness
  end

  # Extend ORM/ODMs for full support (:active_record, :mongoid).
  mattr_accessor :extend_orms
  @@extend_orms = []

  # Ignore errors when restriction options are evaluated
  mattr_accessor :ignore_restriction_errors
  @@ignore_restriction_errors = false

  # Shorthand time and date symbols for restrictions
  mattr_accessor :restriction_shorthand_symbols
  @@restriction_shorthand_symbols = {
    :now   => lambda { Time.current },
    :today => lambda { Date.current }
  }

  # Use the plugin date/time parser which is stricter and extensible
  mattr_accessor :use_plugin_parser
  @@use_plugin_parser = false

  # Default timezone
  self.default_timezone = :utc

  # Set the dummy date part for a time type values.
  self.dummy_date_for_time_type = [ 2000, 1, 1 ]

  def self.parser
    Timeliness
  end

  # Setup method for plugin configuration
  def self.setup
    yield self
    load_orms
  end

  def self.load_orms
    extend_orms.each {|orm| require "validates_timeliness/orm/#{orm}" }
  end
end

require 'validates_timeliness/conversion'
require 'validates_timeliness/validator'
require 'validates_timeliness/helper_methods'
require 'validates_timeliness/attribute_methods'
require 'validates_timeliness/extensions'
require 'validates_timeliness/railtie' if defined?(Rails)
