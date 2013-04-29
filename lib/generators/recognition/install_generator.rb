module Recognition
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("../templates", __FILE__)

      def copy_files
        template "recognition.rb", "config/initializers/recognition.rb"
        template "recognition.yml", "config/recognition.yml"
      end
    end
  end
end