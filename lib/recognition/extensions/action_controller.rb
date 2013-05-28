module Recognition
  module Extensions
    # Extending ActionController
    module ActionController
      def self.included(base)
        base.extend ClassMethods
        base.class_attribute :recognitions
      end
  
      module ClassMethods
        def recognize recognizable, condition
          require "recognition/controllers/recognizer"
          include Recognition::Controllers::Recognizer
          self.recognitions ||= {}
          self.recognitions[condition[:for]] = { recognizable: recognizable, amount: condition[:amount], maximum: condition[:maximum] || 0 }
          after_filter :recognize_actions
        end
      end
    end
  end
end