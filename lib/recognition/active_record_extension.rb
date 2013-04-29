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
      def acts_as_recognizable options = {}
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
        # Due to the lack of ActiveRecord before_filter,
        # we will have to alias the original method in order to intercept
        unless [:create, :update, :destroy].include? condition[:for]
          method = condition[:for]
          define_method "#{method}_with_recognition" do |*args|
            if self.send("#{method}_without_recognition", *args)
              Database.update_points self, condition[:for], self.class.recognitions[condition[:for]]
            end
          end
          alias_method_chain method, 'recognition'
        end
        # For actions that can be intercepted using ActiveRecord callbacks
        after_create :recognize_creating
        #TODO after_save :recognize_updating 
        before_destroy :recognize_destroying
      end
    end

    module RecognizableInstanceMethods #:nodoc:
      def points
        Database.get_user_points self.id
      end
  
      def recognition_counter bucket
        Database.get_user_counter self.id, bucket
      end
  
      def add_initial_points
        Database.update_points self, :initial, self.class.recognitions[:initial]
      end
    end
    
    module ObjectInstanceMethods #:nodoc:
      def recognize_creating
        Database.update_points self, :create, self.class.recognitions[:create] unless self.class.recognitions[:create].nil?
      end
  
      def recognize_updating
        Database.update_points self, :update, self.class.recognitions[:update] unless self.class.recognitions[:update].nil?
      end
  
      def recognize_destroying
        Database.update_points self, :destroy, self.class.recognitions[:destroy] unless self.class.recognitions[:destroy].nil?
      end
  
    end
  end
end