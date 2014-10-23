# ValidatesTimeliness
[![Gem Version][gem-badge]][gem]
[![Build status][build-badge]][build]
[![Coverage Status][coverage-badge]][coverage]

## Description

Complete validation of dates, times and datetimes for Rails 3.x and
ActiveModel.

This is a Rails 4-compatible fork of the
[original validates_timeliness gem][original] by [Adam Meehan][adzap].

## Features

* Adds validation for dates, times and datetimes to ActiveModel
* Handles timezones and type casting of values for you
* Only Rails date/time validation plugin offering complete validation (See
  ORM/ODM support)
* Uses extensible date/time parser (Using
  [timeliness gem][timeliness]. See Plugin Parser)
* Adds extensions to fix Rails date/time select issues (See Extensions)
* Supports I18n for the error messages
* Supports all the Rubies (that any sane person would be using in production).

## Installation

    # in Gemfile
    gem 'jc-validates_timeliness'

    # Run bundler
    $ bundle install

Then run

    $ rails generate validates_timeliness:install

This creates configuration initializer and locale files. In the initializer,
there are a number of config options to customize the plugin.

NOTE: You may wish to enable the plugin parser and the extensions to start.
 Please read those sections first.

## Examples

    validates_datetime :occurred_at

    validates_date :date_of_birth, :before => lambda { 18.years.ago },
                                   :before_message => "must be at least 18 years old"

    validates_datetime :finish_time, :after => :start_time # Method symbol

    validates_date :booked_at, :on => :create, :on_or_after => :today # See Restriction Shorthand.

    validates_time :booked_at, :between => ['9:00am', '5:00pm'] # On or after 9:00AM and on or before 5:00PM
    validates_time :booked_at, :between => '9:00am'..'5:00pm' # The same as previous example
    validates_time :booked_at, :between => '9:00am'...'5:00pm' # On or after 9:00AM and strictly before 5:00PM

    validates_time :breakfast_time, :on_or_after => '6:00am',
                                    :on_or_after_message => 'must be after opening time',
                                    :before => :lunchtime,
                                    :before_message => 'must be before lunch time'

## Usage

To validate a model with a date, time or datetime attribute you just use the
validation method

    class Person < ActiveRecord::Base
      validates_date :date_of_birth, :on_or_before => lambda { Date.current }
      # or
      validates :date_of_birth, :timeliness => {:on_or_before => lambda { Date.current }, :type => :date}
    end

or even on a specific record, per ActiveModel API.

    @person.validates_date :date_of_birth, :on_or_before => lambda { Date.current }

The list of validation methods available are as follows:

    validates_date     - validate value as date
    validates_time     - validate value as time only i.e. '12:20pm'
    validates_datetime - validate value as a full date and time
    validates          - use the :timeliness key and set the type in the hash.

The validation methods take the usual options plus some specific ones to
restrict the valid range of dates or times allowed

Temporal options (or restrictions):

    :is_at        - Attribute must be equal to value to be valid
    :before       - Attribute must be before this value to be valid
    :on_or_before - Attribute must be equal to or before this value to be valid
    :after        - Attribute must be after this value to be valid
    :on_or_after  - Attribute must be equal to or after this value to be valid
    :between      - Attribute must be between the values to be valid. Range or Array of 2 values.

Regular validation options:

    :allow_nil    - Allow a nil value to be valid
    :allow_blank  - Allows a nil or empty string value to be valid
    :if           - Execute validation when :if evaluates true
    :unless       - Execute validation when :unless evaluates false
    :on           - Specify validation context e.g :save, :create or :update. Default is :save.

Special options:

    :ignore_usec  - Ignores microsecond value on datetime restrictions
    :format       - Limit validation to a single format for special cases. Requires plugin parser.

The temporal restrictions can take 4 different value types:

* Date, Time, or DateTime object value
* Proc or lambda object which may take an optional parameter, being the record
  object
* A symbol matching a method name in the model
* String value

When an attribute value is compared to temporal restrictions, they are
compared as the same type as the validation method type. So using
validates_date means all values are compared as dates.

## Configuration

### ORM/ODM Support

The plugin adds date/time validation to ActiveModel for any ORM/ODM that
supports the ActiveModel validations component. However, there is an issue
with most ORM/ODMs which does not allow 100% date/time validation by default.
Specifically, when you assign an invalid date/time value to an attribute, most
ORM/ODMs will only store a nil value for the attribute. This causes an issue
for date/time validation, since we need to know that a value was assigned but
was invalid. To fix this, we need to cache the original invalid value to know
that the attribute is not just nil.

Each ORM/ODM requires a specific shim to fix it. The plugin includes a shim
for ActiveRecord and Mongoid. You can activate them like so

    ValidatesTimeliness.setup do |config|

      # Extend ORM/ODMs for full support (:active_record, :mongoid).
      config.extend_orms = [ :mongoid ]

    end

By default the plugin extends ActiveRecord if loaded. If you wish to extend
another ORM then look at the [wiki page][orm-support] for more information.

It is not required that you use a shim, but you will not catch errors when the
attribute value is invalid and evaluated to nil.

### Error Messages

Using the I18n system to define new defaults:

    en:
      errors:
        messages:
          invalid_date: "is not a valid date"
          invalid_time: "is not a valid time"
          invalid_datetime: "is not a valid datetime"
          is_at: "must be at %{restriction}"
          before: "must be before %{restriction}"
          on_or_before: "must be on or before %{restriction}"
          after: "must be after %{restriction}"
          on_or_after: "must be on or after %{restriction}"

The `%{restriction}` signifies where the interpolation value for the
restriction will be inserted.

You can also use validation options for custom error messages. The following
option keys are available:

    :invalid_date_message
    :invalid_time_message
    :invalid_datetime_message
    :is_at_message
    :before_message
    :on_or_before_message
    :after_message
    :on_or_after_message

Note: There is no :between_message option. The between error message should be
defined using the :on_or_after and :on_or_before (:before in case when
:between argument is a Range with excluded high value, see Examples) messages.

It is highly recommended you use the I18n system for error messages.

### Plugin Parser

The plugin uses the [timeliness gem][timeliness] as a fast, configurable and
extensible date and time parser. You can add or remove valid formats for
dates, times, and datetimes. It is also more strict than the Ruby parser,
which means it won't accept day of the month if it's not a valid number for
the month.

By default the parser is disabled. To enable it:

    # in the setup block
    config.use_plugin_parser = true

Enabling the parser will mean that strings assigned to attributes validated
with the plugin will be parsed using the gem. See the [wiki][plugin-parser]
for more details about the parser configuration.


### Restriction Shorthand

It is common to restrict an attribute to being on or before the current time
or current day. To specify this you need to use a lambda as an option value
e.g. `lambda { Time.current }. This can be tedious noise amongst your
validations for something so common. To combat this the plugin allows you to
use shorthand symbols for often used relative times or dates.

Just provide the symbol as the option value like so:

    validates_date :birth_date, :on_or_before => :today

The :today symbol is evaluated as `lambda { Date.today }`. The :now and :today
symbols are pre-configured. Configure your own like so:

    # in the setup block
    config.restriction_shorthand_symbols.update(
      :yesterday => lambda { 1.day.ago }
    )

### Default Timezone

The plugin needs to know the default timezone you are using when parsing or
type casting values. If you are using ActiveRecord then the default is
automatically set to the same default zone as ActiveRecord. If you are using
another ORM you may need to change this setting.

    # in the setup block
    config.default_timezone = :utc

By default it will be UTC if ActiveRecord is not loaded.

### Dummy Date For Time Types

Given that Ruby has no support for a time-only type, all time type columns are
evaluated as a regular Time class objects with a dummy date value set. Rails
defines the dummy date as 2000-01-01. So a time of '12:30' is evaluated as a
Time value of '2000-01-01 12:30'. If you need to customize this for some
reason you can do so as follows

    # in the setup block
    config.dummy_date_for_time_type = [2009, 1, 1]

The value should be an array of 3 values being year, month and day in that
order.

### Temporal Restriction Errors

When using the validation temporal restrictions there are times when the
restriction option value itself may be invalid. This will add an error to the
model such as 'Error occurred validating birth_date for :before restriction'.
These can be annoying in development or production as you most likely just
want to skip the option if no valid value was returned. By default these
errors are displayed in Rails test mode.

To turn them on/off:

    # in the setup block
    config.ignore_restriction_errors = true

## Extensions

### Strict Parsing for Select Helpers

When using date/time select helpers, the component values are handled by
ActiveRecord using the Time class to instantiate them into a time value. This
means that some invalid dates, such as 31st June, are shifted forward and
treated as valid. To handle these cases in a strict way, you can enable the
plugin extension to treat them as invalid dates.

To activate it, uncomment this line in the initializer:

    # in the setup block
    config.enable_multiparameter_extension!

### Display Invalid Values in Select Helpers

The plugin offers an extension for ActionView to allowing invalid date and
time values to be redisplayed to the user as feedback, instead of a blank
field which happens by default in Rails. Though the date helpers make this a
pretty rare occurrence, given the select dropdowns for each date/time
component, but it may be something of interest.

To activate it, uncomment this line in the initializer:

    # in the setup block
    config.enable_date_time_select_extension!

## Contributors

To see the generous people who have contributed code, take a look at the
[contributors list][contributors].

## Maintainers

* [John Carney][jc]

## License

Copyright (c) 2008 Adam Meehan, released under the MIT license

[jc]:             http://github.com/johncarney
[adzap]:          http://github.com/adzap
[timeliness]:     http://github.com/adzap/timeliness
[orm-support]:    http://github.com/adzap/validates_timeliness/wiki/ORM-Support
[plugin-parser]:  http://github.com/adzap/validates_timeliness/wiki/Plugin-Parser
[original]:       http://github.com/adzap/validates_timeliness
[contributors]:   http://github.com/johncarney/validates_timeliness/contributors
[gem-badge]:      https://badge.fury.io/rb/jc-validates_timeliness.svg
[gem]:            http://badge.fury.io/rb/jc-validates_timeliness
[build-badge]:    https://travis-ci.org/johncarney/validates_timeliness.svg?branch=master
[build]:          https://travis-ci.org/johncarney/validates_timeliness
[coverage-badge]: https://coveralls.io/repos/johncarney/validates_timeliness/badge.png?branch=master
[coverage]:       https://coveralls.io/r/johncarney/validates_timeliness?branch=master
