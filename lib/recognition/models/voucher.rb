module Recognition
  module Models
    module Voucher
      def regenerate_code
        prefix = Recognition::Parser.parse_code_part(self.class.recognitions[:prefix], self)
        suffix = Recognition::Parser.parse_code_part(self.class.recognitions[:suffix], self)
        l = (self.class.recognitions[:code_length] - (prefix.length + suffix.length)) || 10
        dict = [('a'..'z'),('A'..'Z'),(0..9)].map{|i| i.to_a}.flatten
        code = (1..l).map{ dict[rand(dict.length)] }.prepend(prefix).append(suffix).join
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
            # Call custom validators
            if defined? self.class.voucher_validators
              self.class.voucher_validators.each do |validator|
                # quit if any validator returned false
                return if send(validator) == false
              end
            end
            # If all went well:
            Database.redeem_voucher recognizable.id, self.code, self.amount
          end
        end
      end
    
      def redeemable? recognizable
        # default: not redeemable
        pass = false
        # only check if the voucher did not expire
        unless expired?
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
        end
        pass
      end
      
      def expired?
        defined?(self.expires_at) && self.expires_at.present? && self.expires_at < DateTime.now
      end
      
      private
      
      def self.get_user_voucher id, code
        bucket = "Voucher:redeem##{ code }"
        Recognition::Database.get_counter "user:#{id}", bucket
      end
      
      def redeem_voucher id, code, amount
        bucket = "Voucher:redeem##{ code }"
        Database.log(id, amount.to_i, bucket, code)
      end
    
      def transactions page = 0, per = 20
        start = page * per
        stop = (1 + page) * per 
        keypart = "voucher:#{ self.code }"
        Recognition::Database.get_transactions keypart, start, stop
      end
    
    end
  end
end