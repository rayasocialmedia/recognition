require "recognition/extensions/active_record"
require "recognition/extensions/action_controller"
require "rails"

module Recognition
  class Railtie < ::Rails::Railtie
    initializer 'recognition.initialize' do
      ActiveSupport.on_load(:active_record) do
        ActiveRecord::Base.send :include, Recognition::Extensions::ActiveRecord
      end
      ActiveSupport.on_load(:action_controller) do
        ActionController::Base.send(:include, Recognition::Extensions::ActionController)
      end
    end
  end
end