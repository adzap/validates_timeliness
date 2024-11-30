module ValidatesTimeliness
  module Extensions
    autoload :TimelinessDateTimeSelect, 'validates_timeliness/extensions/date_time_select'
  end

  def self.enable_date_time_select_extension!
    require 'uri' # Do we need this? No, but the test suite fails without it.
    ::ActionView::Helpers::Tags::DateSelect.send(:prepend, ValidatesTimeliness::Extensions::TimelinessDateTimeSelect)
  end

  def self.enable_multiparameter_extension!
    require 'validates_timeliness/extensions/multiparameter_handler'
  end
end
