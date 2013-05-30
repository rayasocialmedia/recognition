require 'recognition/models/redeemable'

module Recognition
  module Models
    module Gift
      include Recognition::Models::Redeemable
      
      def redeemable? recognizable
        pass = false
        if recognizable.points >= self.amount
          if is_redeemable?(recognizable)
            pass = true
          end
        else
          errors.add(:base, "#{self.class.to_s} can not be redeemed: insufficient points")
          pass = false
        end
        pass
      end
      
      def execute_redemption id
        actual_amount = (self.amount.to_i * -1)
        Recognition::Database.redeem id, bucket, self.class.to_s.downcase, self.code, actual_amount
      end
    end
  end
end