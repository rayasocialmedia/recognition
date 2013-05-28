module Recognition
  module Controllers
    module Recognizer
      def recognize_actions
        action = params[:action].to_sym
        self.class.recognitions[action][:proc_params] = params
        if self.class.recognitions.keys.include? action
          # update_points current_user.id, action, self.class.recognitions[action][:amount]
          Database.update_points self, action, self.class.recognitions[action]
        end
      end
    end
  end
end