require 'date'
require 'active_support/time_with_zone'
require 'active_support/core_ext/hash/except'
require 'active_support/core_ext/string/conversions'
require 'active_support/core_ext/date/acts_like'
require 'active_support/core_ext/date/conversions'
require 'active_support/core_ext/date/zones'
require 'active_support/core_ext/time/acts_like'
require 'active_support/core_ext/time/conversions'
require 'active_support/core_ext/time/zones'
require 'active_support/core_ext/date_time/acts_like'
require 'active_support/core_ext/date_time/conversions'
require 'active_support/core_ext/date_time/zones'

module ValidatesTimeliness
  autoload :VERSION, 'validates_timeliness/version'

  # Add validation helpers to these classes
  mattr_accessor :extend_classes
  @@extend_classes = []

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
    extend_classes.each {|klass|
      klass.send(:include, ValidatesTimeliness::HelperMethods)
      klass.send(:include, ValidatesTimeliness::AttributeMethods)
    }
  end
end

require 'validates_timeliness/conversion'
require 'validates_timeliness/validator'
require 'validates_timeliness/helper_methods'
require 'validates_timeliness/attribute_methods'
require 'validates_timeliness/extensions'
