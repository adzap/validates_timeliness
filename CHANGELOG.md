# 8.0.0 [2024-12-31]
*   Support Rails v8.x
*   Support passing non-reserved validation options to errors

# 7.0.0 [2024-11-30]
*   Support Rails v7.x
*   Removed all method overrides in ActiveModel now that the datetime type correctly stores before_type_cast values.

# 6.0.1 [2023-01-12]
*   TODO need to complete this

# 6.0.0 [2022-10-20]
*   TODO need to complete this

# 5.0.0 [2021-04-03]
*   Fix DateTimeSelect extension support (AquisTech)
*   Relaxed Timeliness dependency version which allows for >= 0.4.0 with
    threadsafety fix for use_us_formats and use_euro_formats for hot switching

	in a request.
*   Add initializer to ensure Timeliness v0.4+ ambiguous date config is set
    correctly when using `use_euro_formats` or `remove_use_formats'.
*   Add Ruby 3 compatibility
*   Add Rails 6.1 compatibility


Breaking Changes
*   Update Multiparameter extension to use ActiveRecord type classes with
    multiparameter handling which stores a hash of multiparamter values as the
    value before type cast, no longer a mushed datetime string
*   Removed all custom plugin attribute methods and method overrides in favour
    using ActiveModel type system


# 4.1.0 [2019-06-11]
*   Relaxed Timeliness dependency version to >= 0.3.10 and < 1, which allows
    version 0.4 with threadsafety fix for use_us_formats and use_euro_formats
    hot switching in a request.


# 4.0.2 [2016-01-07]
*   Fix undefine_generated_methods ivar guard setting to false


# 4.0.1 [2016-01-06]
*   Fix undefine_generated_methods thread locking bug
*   Created an ActiveModel ORM, for manual require if using without any full
    blown ORM


# 4.0.0 [2015-12-29]
*   Extracted mongoid support into
    https://github.com/adzap/validates_timeliness-mongoid which is broken (not
    supported anymore).
*   Fixed Rails 4.0, 4.1 and 4.2 compatability issues
*   Upgrade specs to RSpec 3
*   Added travis config
*   Huge thanks to @johncarney for keeping it alive with his fork
    (https://github.com/johncarney/validates_timeliness)


# 3.0.15 [2015-12-29]
*   Fixes mongoid 3 support and removes mongoid 2 support(johnnyshields)
*   Some documentation/comments tidying
*   Some general tidying up


# 3.0.14 [2012-08-23]
*   Fix for using validates :timeliness => {} form to correctly add attributes
    to timeliness validated attributes.


# 3.0.13 [2012-08-21]
*   Fix ActiveRecord issues with using plugin parser by using old way of
    caching values.
*   Allow any ActiveRecord non-column attribute to be validated


# 3.0.12 [2012-06-23]
*   Fix load order issue when relying on Railtie to load ActiveRecord
    extension


# 3.0.11 [2012-04-01]
*   Change dependency on Timeliness version due to a broken release


# 3.0.10 [2012-03-26]
*   Fix for ActiveRecord shim and validation with :allow_blank => true in AR
    3.1+. Fixes issue#52.


# 3.0.9 [2012-03-26]
*   ActiveRecord 3.1+ suport
*   Fixes for multiparameter extension with empty date values (thanks @mogox,
    @Sharagoz)


# 3.0.8 [2011-12-24]
*   Remove deprecated InstanceMethods module when using AS::Concern
    (carlosantoniodasilva)
*   Update Mongoid shim for v2.3 compatability.


# 3.0.7 [2011-09-21]
*   Fix ActiveRecord before_type_cast extension for non-dirty attributes.
*   Don't override AR before_type_cast for >= 3.1.0 which now has it's own
    implementation for date/time attributes.
*   Fix DateTimeSelect extension to convert params to integers (#45)
*   Add #change method to DateTimeSelect extension (@trusche, #45)
*   Cleanup Mongoid shim.


# 3.0.6 [2011-05-09]
*   Fix for AR type conversion for date columns when using plugin parser.
*   Add timeliness_type_cast_code for ORM specific type casting after parsing.


# 3.0.5 [2011-01-29]
*   Fix for Conversion#parse when given nil value (closes issue #34)


# 3.0.4 [2011-01-22]
*   Fix :between option which was being ignored (ebeigarts)
*   Use class_attribute to remove deprecated class_inheritable_accessor
*   Namespace copied validator class to ActiveModel::Validations::Timeliness
    for :timeliness option


# 3.0.3 [2010-12-11]
*   Fix validation of values which don't respond to to_date or to_time
    (renatoelias)


# 3.0.2 [2010-12-04]
*   Fix AR multiparameter extension for Date columns
*   Update to Timeliness 0.3.2 for zone abbreviation and offset support


# 3.0.1 [2010-11-02]
*   Generate timeliness write methods in an included module to allow
    overriding in model class (josevalim)


# 3.0.0 [2010-10-18]
*   Rails 3 and ActiveModel compatibility
*   Uses ActiveModel::EachValidator as validator base class.
*   Configuration settings stored in ValidatesTimeliness module only.
    ValidatesTimeliness.setup block to configure.
*   Parser extracted to the Timeliness gem http://github.com/adzap/timeliness
*   Parser is disabled by default. See initializer for enabling it.
*   Removed RSpec matcher. Encouraged poor specs by copy-pasting from spec to
    model, or worse, the other way round.
*   Method override for parsing and before type cast values is on validated
    attributes only. Old version handled all date/datetime columns, validates
    or not. Too intrusive.
*   Add validation helpers to classes using extend_orms config setting. e.g.
    conf.extend_orms = [ :active_record ]
*   Changed :between option so it is split into :on_or_after and :on_or_before
    option values. The error message for either failing check will be used
    instead of a between error message.
*   Provides :timeliness option key for validates class method. Be sure to
    pass :type option as well e.g. :type => :date.
*   Allows validation methods to be called on record instances as per
    ActiveModel API.
*   Performs parsing (optional) and raw value caching (before_type_cast) on
    validated attributes only. It used to be all date, time and datetime
    attributes.


# 2.3.1 [2010-03-19]
*   Fixed bug where custom attribute writer method for date/times were being
    overriden


# 2.3.0 [2010-02-04]
*   Backwards incompatible change to :equal_to option. Fixed error message
    clash with :equal_to option which exists in Rails already. Option is now
    :is_at.
*   Fixed I18n support so it returns missing translation message instead of
    error
*   Fixed attribute method bug. Write method was bypassed when method was
    first generated and used Rails default parser.
*   Fixed date/time selects when using enable_datetime_select_extension! when
    some values empty
*   Fixed ISO8601 datetime format which is now split into two formats
*   Changed I18n error value format to fallback to global default if missing
    in locale
*   Refactored date/time select invalid value extension to use param values.
    Functionality will be extracted from plugin for v3.


# 2.2.2 [2009-09-19]
*   Fixed dummy_time using make_time to respect timezone. Fixes 1.9.1 bug.


# 2.2.1 [2009-09-12]
*   Fixed dummy date part for time types in Validator.type_cast_value
*   No more core extensions! Removed dummy_time methods.


# 2.2.0 [2009-09-12]
*   Ruby 1.9 support!
*   Customise dummy date values for time types. See DUMMY DATE FOR TIME TYPES.
*   Fixed matcher conflict with Shoulda. Load plugin matcher manually now see
    matcher section in README
*   Fixed :ignore_usec when used with :with_time or :with_date
*   Some clean up and refactoring


# 2.1.0 [2009-06-20]
*   Added ambiguous year threshold setting in Formats class to customize the
    threshold for 2 digit years (See README)
*   Fixed interpolation values in custom error message for Rails 2.2+
*   Fixed custom I18n local override of en locale
*   Dramatically simplified ActiveRecord monkey patching and hackery


# 2.0.0 [2009-04-12]
*   Error value formats are now specified in the i18n locale file instead of
    updating plugin hash. See OTHER CUSTOMISATION section in README.
*   Date/time select helper extension is disabled by default. To enable see
    DISPLAY INVALID VALUES IN DATE HELPERS section in README to enable.
*   Added :format option to limit validation to a single format if desired
*   Matcher now supports :equal_to option
*   Formats.parse can take :include_offset option to include offset value from
    string in seconds, if string contains an offset. Offset not used in rest
    of plugin yet.
*   Refactored to remove as much plugin code from ActiveRecord as possible.


# 1.1.7 [2009-03-26]
*   Minor change to multiparameter attributes which I had not properly
    implemented for chaining


# 1.1.6 [2009-03-19]
*   Rail 2.3 support
*   Added :with_date and :with_time options. They allow an attribute to be
    combined with another attribute or value to make a datetime value for
    validation against the temporal restrictions
*   Added :equal_to option
*   Option key validation
*   Better behaviour with other plugins using alias_method_chain on
    read_attribute and define_attribute_methods
*   Added option to enable datetime_select extension for future use to
    optionally enable. Enabled by default until version 2.
*   Added :ignore_usec option for datetime restrictions to be compared without
    microsecond
*   some refactoring


# 1.1.5 [2009-01-21]
*   Fixed regex for 'yy' format token which wasn't greedy enough for date
    formats ending with year when a datetime string parsed as date with a 4
    digit year


# 1.1.4 [2009-01-13]
*   Make months names respect i18n in Formats


# 1.1.3 [2009-01-13]
*   Fixed bug where time and date attributes still being parsed on read using
    Rails default parser [reported by Brad (pvjq)]


# 1.1.2 [2009-01-12]
*   Fixed bugs
    *   matcher failing for custom error message without interpolation keys
        using I18n
    *   validator custom error messages not being extracted



# 1.1.1 [2009-01-03]
*   Fixed bug in matcher for options local variable


# 1.1.0 [2009-01-01]
*   Added between option


# 1.0.0 [2008-12-06]
*   Gemified!
*   Refactor of plugin into a Data Mapper style validator class which makes
    for a cleaner implementation and possible future MerbData Mapper support
*   Added Rails 2.2 i18n support. Plugin error messages can specified in
    locale files. See README.
*   ignore_datetime_restriction_errors setting has been moved from AR to
    ValidatesTimeliness::Validator.ignore_restriction_errors
*   date_time_error_value_formats setting has been moved from AR to
    ValidatesTimeliness::Validator.error_value_formats
*   Namespaced modules and specs
*   Clean up of specs
*   fixed a few bugs
    *   accessor methods not generating properly due method name stored as
        symbol in generated_attributes which fails on lookup
    *   force value assigned to time/datetime attributes to time objects



# 0.1.0 [2008-12-06]
*   Tagged plugin as version 0.1.0


# 2008-11-13
*   allow uppercase meridian to be valid [reported by Alex
    (http://alex.digns.com/)]


# 2008-10-28
*   fixed bug when dirty attributes not reflecting change when attribute
    changed from time value to nil [reported by Brad (pvjq)]
*   fixes for Rails 2.2 compatibility. Will refactor in to Rails version
    specific branches in the future.


# 2008-09-24
*   refactored attribute write method definitions


# 2008-08-25
*   fixed bug for non-timezone write method not updating changed attributes
    hash [reported by Sylvestre Mergulhão]


# 2008-08-22
*   fixed bug with attribute cache not clearing on write for date and time
    columns [reported by Sylvestre Mergulhão]
*   parse method returns Date object for date column assigned string as per
    normal Rails behaviour
*   parse method returns same object type when assigned Date or Time object as
    per normal Rails behaviour


# 2008-08-07
*   modified matcher option value parsing to allow same value types as
    validation method
*   fixed matcher message


# 2008-08-02
*   refactored validation
*   refactored matcher


# 2008-07-30
*   removed setting values to nil when validation fails to preserve
    before_type_cast value

