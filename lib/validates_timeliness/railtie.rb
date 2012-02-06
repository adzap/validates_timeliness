module ValidatesTimeliness
  class Railtie < Rails::Railtie
    initializer "validates_timeliness.initialize_active_record", :after => 'active_record.initialize_timezone' do
      ValidatesTimeliness.default_timezone = ActiveRecord::Base.default_timezone
    end

    initializer "validates_timeliness.initialize_restriction_errors" do
      ValidatesTimeliness.ignore_restriction_errors = !Rails.env.test?
    end
  end
end

ActiveSupport.on_load(:active_record) do
  ValidatesTimeliness.extend_orms = [ :active_record ]
end
