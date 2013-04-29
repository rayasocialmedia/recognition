require "recognition/active_record_extension"
require "recognition/action_controller_extension"
require "rails"

module Recognition
  class Railtie < Rails::Railtie
    initializer 'recognition.initialize' do
      ActiveSupport.on_load(:active_record) do
        ActiveRecord::Base.send :include, ActiveRecordExtension
      end
      ActiveSupport.on_load(:action_controller) do
        ActionController::Base.send(:include, ActionControllerExtension)
      end
    end
    # 
    # initializer 'recognition.database' do
    #   #TODO: use a Rails initializer
    #   $REDIS = Redis.new #(host: 'localhost', port: redis_config[:port])
    # end
  end
end