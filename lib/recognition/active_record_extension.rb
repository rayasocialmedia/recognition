require "recognition/database"

module Recognition
  module ActiveRecordExtension
    def self.included(base)
      base.extend ClassMethods
      base.class_attribute :recognitions
      base.class_attribute :recognizable
    end

    module ClassMethods #:nodoc:
      # to be called from user-model
      def acts_as_recognizeable options = {}
        include RecognizableInstanceMethods
        self.recognizable = true
        self.recognitions ||= {}
        self.recognitions[:initial] = {
          amount: options[:initial]
        }
        after_save :add_initial_points
      end
  
      def recognize recognizable, condition
        include ObjectInstanceMethods
        self.recognitions ||= {}
        self.recognitions[condition[:for]] = {
          recognizable: recognizable,
          gain: condition[:gain],
          loss: condition[:loss],
          maximum: condition[:maximum]
        }
        after_save :recognize_creating
        #TODO after_save :recognize_updating 
        before_destroy :recognize_destroying
      end
    end

    module RecognizableInstanceMethods #:nodoc:
      def points
        Database.get_user_points self.id
      end
  
      def add_initial_points
        Database.add_points self, :initial, self.class.recognitions[:initial]
      end
    end
    
    module ObjectInstanceMethods #:nodoc:
      def recognize_creating
        Database.add_points self, :create, self.class.recognitions[:create] unless self.class.recognitions[:create].nil?
      end
  
      def recognize_updating
        Database.add_points self, :update, self.class.recognitions[:update] unless self.class.recognitions[:update].nil?
      end
  
      def recognize_destroying
        Database.add_points self, :destroy, self.class.recognitions[:destroy] unless self.class.recognitions[:destroy].nil?
      end
  
    end
  end
end