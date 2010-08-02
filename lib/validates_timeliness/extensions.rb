module ValidatesTimeliness
  module Extensions
    autoload :DateTimeSelect, 'validates_timeliness/extensions/date_time_select'
  end

  def self.enable_date_time_select_extension!
    ::ActionView::Helpers::InstanceTag.send(:include, ValidatesTimeliness::Extensions::DateTimeSelect)
  end
end
