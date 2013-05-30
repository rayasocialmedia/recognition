module Recognition
  module Models
    module Redeemable
      def regenerate_code
        self.class.recognitions[:code_length] = 10 if self.class.recognitions[:code_length].nil?
        prefix = Recognition::Parser.parse_code_part(self.class.recognitions[:prefix], self)
        suffix = Recognition::Parser.parse_code_part(self.class.recognitions[:suffix], self)
        l = (self.class.recognitions[:code_length] - (prefix.length + suffix.length))
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
      
      def expired?
        defined?(self.expires_at) && self.expires_at.present? && self.expires_at < DateTime.now
      end
      
      def is_redeemable? recognizable
        # default: not redeemable
        pass = false
        # only check if the redeemable did not expire
        if expired?
          Recognition.log self.class.to_s.downcase.to_sym, "validation error for #{self.class.to_s}##{self.id}: expired"
        else
          # has the redeemable ever been redeemed?
          if transactions.any?
            # has the redeemable ever been redeemed by this user?
            if get_user_counter(recognizable.id) != 0
              Recognition.log self.class.to_s.downcase.to_sym, "validation error for #{self.class.to_s}##{self.id}: user has already redeemed the voucher"
              pass = false
              # is the redeemable reusable?
            elsif defined?(self.reusable?) && self.reusable?
              pass = true
            end
          else
            pass = true
          end
        end
        pass
      end
      
      def redeem recognizable
        # Make sure we have an amount beforehand
        if defined? self.amount
          if self.redeemable? recognizable
            # Call custom validators
            if defined? self.class.redemption_validators
              self.class.redemption_validators.each do |validator|
                # quit if any validator returned false
                if send(validator) == false
                  Recognition.log self.class.to_s.downcase.to_sym, "validation error for #{self.class.to_s}##{self.id}: custom validation error"
                  return
                end
              end
            end
            # If all went well:
            execute_redemption recognizable.id
          end
        else
          Recognition.log self.class.to_s.downcase.to_sym, "validation error for #{self.class.to_s}##{self.id}: amount is nil"
        end
      end
      
    
      def bucket
        "#{self.class.to_s.downcase}:#{ self.code }"
      end
      
      def get_user_counter id
        Recognition::Database.get_counter "user:#{id}", bucket
      end
      
      def transactions page = 0, per = 20
        start = page * per
        stop = (1 + page) * per 
        Recognition::Database.get_transactions bucket, start, stop
      end
    
    end
  end
end