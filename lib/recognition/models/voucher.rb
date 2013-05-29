require 'recognition/models/redeemable'

module Recognition
  module Models
    module Voucher
      include Recognition::Models::Redeemable
      
      def redeemable? recognizable
        is_redeemable? recognizable
      end
      
      def execute_redemption id
        Recognition::Database.redeem id, bucket, self.class.to_s.downcase, self.code, self.amount.to_i
      end
    end
  end
end