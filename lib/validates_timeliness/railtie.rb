module ValidatesTimeliness
  class Railtie < Rails::Railtie
    initializer "validates_timeliness.initialize_active_record", :after => 'active_record.initialize_timezone' do
      ActiveSupport.on_load(:active_record) do
        ValidatesTimeliness.default_timezone = ActiveRecord::Base.default_timezone
        ValidatesTimeliness.extend_orms << :active_record
        ValidatesTimeliness.load_orms
      end
    end

    initializer "validates_timeliness.initialize_restriction_errors" do
      ValidatesTimeliness.ignore_restriction_errors = !Rails.env.test?
    end
  end
end
