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
        include RecognizableInstanceMethods
        self.recognizable = true
        self.recognitions ||= {}
        self.recognitions[:initial] = {
          amount: options[:initial]
        }
        after_save :add_initial_points
        
      end
  
      # to be called from other models
      def recognize recognizable, condition
        include ObjectInstanceMethods
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
        include VoucherInstanceMethods
        self.recognitions = options
        before_create :regenerate_code
      end
    end

    module RecognizableInstanceMethods
      # Determine user current balance of points
      def points
        Database.get_user_points self.id
      end
  
      def recognition_counter bucket
        Database.get_user_counter self.id, bucket
      end
  
      def add_initial_points
        Database.update_points self, :initial, self.class.recognitions[:initial]
      end

      def update_points amount, bucket
        Database.log(self.id, amount.to_i, bucket)
      end
      
      def transactions page = 0, per = 20
        Database.get_user_transactions self.id, page, per
      end
    end
    
    module ObjectInstanceMethods
      def recognize_creating
        if self.id_changed? # Unless we are creating
          Database.update_points self, :create, self.class.recognitions[:create] unless self.class.recognitions[:create].nil?
        end
      end
  
      def recognize_updating
        unless self.id_changed? # Unless we are creating
          Database.update_points self, :update, self.class.recognitions[:update] unless self.class.recognitions[:update].nil?
        end
      end
  
      def recognize_destroying
        Database.update_points self, :destroy, self.class.recognitions[:destroy] unless self.class.recognitions[:destroy].nil?
      end
  
    end
    
    module VoucherInstanceMethods
      def regenerate_code
        l = self.class.recognitions[:code_length] || 10
        dict = [('a'..'z'),('A'..'Z'),(0..9)].map{|i| i.to_a}.flatten
        code = (1..l).map{ dict[rand(dict.length)] }.join
        # Prevent code collision at all costs
        if self.class.to_s.constantize.find_all_by_code(code).any?
          regenerate_code
        else
          self.code = code
          self
        end
      end
      
      def redeem recognizable
        # Make sure we have an amount beforehand
        if defined? self.amount
          if self.redeemable? recognizable
            Database.redeem_voucher recognizable.id, self.code, self.amount
          end
        end
      end
      
      def redeemable? recognizable
        # default: not redeemable
        pass = false
        # has the voucher ever been redeemed?
        if Database.get_voucher_transactions(self.code).any?
          # has the voucher ever been redeemed by this user?
          if Database.get_user_voucher(recognizable.id, code) != 0
            pass = false
          # is the voucher reusable?
          elsif defined?(self.reusable?) && self.reusable?
            pass = true
          end
        else
          pass = true
        end
        pass
      end
      
    end
  end
end