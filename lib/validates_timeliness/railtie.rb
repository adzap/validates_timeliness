module ValidatesTimeliness
  class Railtie < Rails::Railtie
    initializer "validates_timeliness.initialize_active_record", :after => 'active_record.initialize_timezone' do
      ActiveSupport.on_load(:active_record) do
        ValidatesTimeliness.default_timezone = (::ActiveRecord.respond_to?(:default_timezone) ? ::ActiveRecord.default_timezone : ::ActiveRecord::Base.default_timezone)
        ValidatesTimeliness.extend_orms << :active_record
        ValidatesTimeliness.load_orms
      end
    end

    initializer "validates_timeliness.initialize_restriction_errors" do
      ValidatesTimeliness.ignore_restriction_errors = !Rails.env.test?
    end

    initializer "validates_timeliness.initialize_timeliness_ambiguous_date_format", :after => :load_config_initializers do
      if Timeliness.respond_to?(:ambiguous_date_format) # i.e. v0.4+
        # Set default for each new thread if you have changed the default using
        # the format switching methods.
        Timeliness.configuration.ambiguous_date_format = Timeliness::Definitions.current_date_format
      end
    end
  end
end
