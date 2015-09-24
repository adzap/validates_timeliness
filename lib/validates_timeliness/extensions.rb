module ValidatesTimeliness
  module Extensions
    autoload :DateTimeSelect,         'validates_timeliness/extensions/date_time_select'
    if ActiveRecord::VERSION::MAJOR < 4
      autoload :MultiparameterHandler, 'validates_timeliness/extensions/multiparameter_handler'
    else
      autoload :AttributeAssignment,     'validates_timeliness/extensions/attribute_assignment'
      autoload :MultiparameterAttribute, 'validates_timeliness/extensions/multiparameter_attribute'
    end
  end

  def self.enable_date_time_select_extension!

    if ActiveRecord::VERSION::MAJOR < 4
      ::ActionView::Helpers::InstanceTag.send(:include, ValidatesTimeliness::Extensions::DateTimeSelect)
    else
      ::ActionView::Helpers::Tags::DateSelect.send(:include, ValidatesTimeliness::Extensions::DateTimeSelect)
    end
  end

  def self.enable_multiparameter_extension!
    if ActiveRecord::VERSION::MAJOR < 4
      ::ActiveRecord::Base.send(:include, ValidatesTimeliness::Extensions::MultiparameterHandler)
    else
      ::ActiveRecord::Base.send(:include, ValidatesTimeliness::Extensions::AttributeAssignment)
      ::ActiveRecord::AttributeAssignment::MultiparameterAttribute.send(:include, ValidatesTimeliness::Extensions::MultiparameterAttribute)
    end
  end
end
