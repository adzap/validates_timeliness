module ValidatesTimeliness
  module Generators
    class InstallGenerator < Rails::Generators::Base
      desc "Copy ValidatesTimeliness default files"
      source_root File.expand_path('../templates', __FILE__)

      def copy_initializers
        copy_file 'validates_timeliness.rb', 'config/initializers/validates_timeliness.rb'
      end

      def copy_locale_file
        copy_file 'en.yml', 'config/locales/validates_timeliness.en.yml'
      end
    end
  end
end
