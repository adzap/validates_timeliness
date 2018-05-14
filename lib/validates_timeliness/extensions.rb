module ValidatesTimeliness
  module Extensions
    autoload :TimelinessDateTimeSelect, 'validates_timeliness/extensions/date_time_select'
  end

  def self.enable_date_time_select_extension!
    ::ActionView::Helpers::Tags::DateSelect.send(:prepend, ValidatesTimeliness::Extensions::TimelinessDateTimeSelect)
  end

  def self.enable_multiparameter_extension!
    require 'validates_timeliness/extensions/multiparameter_handler'
  end
end
