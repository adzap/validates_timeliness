require 'date'
require 'forwardable'

require 'timeliness/configuration'
require 'timeliness/helpers'
require 'timeliness/definitions'
require 'timeliness/format'
require 'timeliness/format_set'
require 'timeliness/parser'
require 'timeliness/version'

module Timeliness
  class << self
    extend Forwardable
    def_delegators Parser, :parse, :_parse
    def_delegators Definitions, :add_formats, :remove_formats, :use_us_formats, :use_euro_formats
    attr_accessor :configuration

    def_delegators :configuration, :default_timezone, :date_for_time_type, :ambiguous_date_format, :ambiguous_year_threshold
    def_delegators :configuration, :default_timezone=, :date_for_time_type=, :ambiguous_date_format=, :ambiguous_year_threshold=
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
  end
end

Timeliness::Definitions.compile_formats
