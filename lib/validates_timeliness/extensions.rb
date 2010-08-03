module ValidatesTimeliness
  module Extensions
    autoload :DateTimeSelect,       'validates_timeliness/extensions/date_time_select'
    autoload :MultiparameterParser, 'validates_timeliness/extensions/multiparameter_parser'
  end

  def self.enable_date_time_select_extension!
    ::ActionView::Helpers::InstanceTag.send(:include, ValidatesTimeliness::Extensions::DateTimeSelect)
  end

  def self.enable_multiparameter_parser!
    ::ActiveRecord::Base.send(:include, ValidatesTimeliness::Extensions::MultiparameterParser)
  end
end
