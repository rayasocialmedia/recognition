require "recognition/database"

module Recognition
  # Extending ActiveRecord
  module ActionControllerExtension
    def self.included(base)
      base.extend ClassMethods
      base.class_attribute :recognitions
    end
  
    module ClassMethods
      def recognize recognizable, condition
        include InstanceMethods
        self.recognitions ||= {}
        self.recognitions[condition[:for]] = { recognizable: recognizable, amount: condition[:amount], maximum: condition[:maximum] || 0 }
        after_filter :recognize_actions
      end
      
    end
    
    module InstanceMethods
      def recognize_actions
        action = params[:action].to_sym
        if self.class.recognitions.keys.include? action
          # update_points current_user.id, action, self.class.recognitions[action][:amount]
          Database.update_points self, action, self.class.recognitions[action]
        end
      end
    end
  end
end