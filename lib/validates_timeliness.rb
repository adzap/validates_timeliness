require 'date'
require 'active_support/core_ext/hash/except'
require 'active_support/core_ext/string/conversions'
require 'active_support/core_ext/date/acts_like'
require 'active_support/core_ext/date/conversions'
require 'active_support/core_ext/time/acts_like'
require 'active_support/core_ext/time/conversions'
require 'active_support/core_ext/date_time/acts_like'
require 'active_support/core_ext/date_time/conversions'

module ValidatesTimeliness
  autoload :Parser,  'validates_timeliness/parser'
  autoload :VERSION, 'validates_timeliness/version'

  # Add plugin to supported ORMs (:active_record, :mongoid)
  mattr_accessor :extend_orms
  @@extend_orms = [ defined?(ActiveRecord) && :active_record ].compact

  # User the plugin date/time parser which is stricter and extendable
  mattr_accessor :use_plugin_parser
  @@use_plugin_parser = false

  # Default timezone
  mattr_accessor :default_timezone
  @@default_timezone = defined?(ActiveRecord) ? ActiveRecord::Base.default_timezone : :utc

  # Set the dummy date part for a time type values.
  mattr_accessor :dummy_date_for_time_type
  @@dummy_date_for_time_type = [ 2000, 1, 1 ]

  # Ignore errors when restriction options are evaluated
  mattr_accessor :ignore_restriction_errors
  @@ignore_restriction_errors = defined?(Rails) ? !Rails.env.test? : false

  # Shorthand time and date symbols for restrictions
  mattr_accessor :restriction_shorthand_symbols
  @@restriction_shorthand_symbols = {
    :now   => lambda { Time.now },
    :today => lambda { Date.today }
  }

  # Setup method for plugin configuration
  def self.setup
    yield self
    extend_orms.each {|orm| require "validates_timeliness/orm/#{orm}" }
  end
end

require 'validates_timeliness/conversion'
require 'validates_timeliness/validator'
require 'validates_timeliness/helper_methods'
require 'validates_timeliness/attribute_methods'
require 'validates_timeliness/extensions'
