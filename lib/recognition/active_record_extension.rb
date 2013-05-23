require "recognition/database"

module Recognition
  module ActiveRecordExtension
    def self.included(base)
      base.extend ClassMethods
      base.class_attribute :recognitions
      base.class_attribute :recognizable
    end

    module ClassMethods
      # to be called from user model
      def acts_as_recognizable options = {}
        require "recognition/activerecord/recognizable"
        include Recognition::ActiveRecord::Recognizable
        self.recognizable = true
        self.recognitions ||= {}
        self.recognitions[:initial] = {
          amount: options[:initial]
        }
        after_save :add_initial_points
      end
  
      # to be called from other models
      def recognize recognizable, condition
        require "recognition/activerecord/model"
        include Recognition::ActiveRecord::Model
        self.recognitions ||= {}
        self.recognitions[condition[:for]] = {
          recognizable: recognizable,
          bucket: condition[:group],
          gain: condition[:gain],
          loss: condition[:loss],
          maximum: condition[:maximum]
        }
        # Due to the lack of ActiveRecord before_filter,
        # we will have to alias the original method in order to intercept
        if [:create, :update, :destroy].include? condition[:for]
          include ActiveModel::Dirty
        else
          method = condition[:for]
          define_method "#{method}_with_recognition" do |*args|
            if self.send("#{method}_without_recognition", *args)
              Database.update_points self, condition[:for], self.class.recognitions[condition[:for]]
            end
          end
          alias_method_chain method, 'recognition'
        end
        # For actions that can be intercepted using ActiveRecord callbacks
        before_destroy :recognize_destroying
        after_save :recognize_updating 
        # We use after_save for creation to make sure all associations
        # have been persisted
        after_save :recognize_creating
      end

      # to be called from user-model
      def acts_as_voucher options = {}
        require "recognition/activerecord/voucher"
        include Recognition::ActiveRecord::Voucher
        self.recognitions = options
        cattr_accessor :voucher_validators
        def self.validates_voucher_redmeption validators
          self.voucher_validators ||= []
          self.voucher_validators << validators
          self.voucher_validators.flatten!
        end
        before_create :regenerate_code
      end
    end
  end
end