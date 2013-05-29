require 'recognition/models/redeemable'

module Recognition
  module Models
    module Gift
      include Recognition::Models::Redeemable
      
      def redeemable? recognizable
        recognizable.points >= self.amount && is_redeemable?(recognizable)
      end
      
      def execute_redemption id
        actual_amount = (self.amount.to_i * -1)
        Recognition::Database.redeem id, bucket, self.class.to_s.downcase, self.code, actual_amount
      end
    end
  end
end