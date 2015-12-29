module ValidatesTimeliness
  module Extensions
    autoload :DateTimeSelect, 'validates_timeliness/extensions/date_time_select'
  end

  def self.enable_date_time_select_extension!
    ::ActionView::Helpers::Tags::DateSelect.send(:include, ValidatesTimeliness::Extensions::DateTimeSelect)
  end

  def self.enable_multiparameter_extension!
    require 'validates_timeliness/extensions/multiparameter_handler'
  end
end
