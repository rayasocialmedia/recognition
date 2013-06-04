require 'recognition/extensions/active_record'
require 'recognition/extensions/action_controller'

module Recognition
  module Rails
    class Engine < ::Rails::Engine
      config.generators do |g|
        g.test_framework      :rspec,        :fixture => false
        g.fixture_replacement :factory_girl, :dir => 'spec/factories'
        g.assets false
        g.helper false
      end
      initializer 'recognition.initialize' do
        ActiveSupport.on_load(:active_record) do
          ActiveRecord::Base.send :include, Recognition::Extensions::ActiveRecord
        end
        ActiveSupport.on_load(:action_controller) do
          ActionController::Base.send(:include, Recognition::Extensions::ActionController)
        end
      end
      initializer 'recognition.logger' do
        Recognition.logger = ::Rails.logger
      end
    end
  end
end
