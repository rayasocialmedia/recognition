require "recognition/transaction"

module Recognition
  module Database
    def self.log id, amount, bucket
      hash = Time.now.to_f.to_s
      Recognition.backend.multi do
        # Recognition.backend.incrby "recognition:user:#{ id }:points", amount
        Recognition.backend.hincrby "recognition:user:#{ id }:counters", 'points', amount
        Recognition.backend.hincrby "recognition:user:#{ id }:counters", bucket, amount
        Recognition.backend.zadd "recognition:user:#{ id }:transactions", hash, { hash: hash, amount: amount, bucket: bucket, datetime: DateTime.now.to_s }.to_json
        Recognition.backend.zadd 'recognition:transactions', hash, { hash: hash, id: id, amount: amount, bucket: bucket, datetime: DateTime.now.to_s }.to_json
      end
    end
    
    def self.record transaction
      unless transaction.class.to_s == Recognition::Transaction
        raise ArgumentError, 'parameter should be of type Recognition::Transaction'
      end
      hash = Time.now.to_f.to_s
      Recognition.backend.multi do
        # Recognition.backend.incrby "recognition:user:#{ id }:points", amount
        Recognition.backend.hincrby "recognition:user:#{ id }:counters", 'points', transactions.amount
        Recognition.backend.hincrby "recognition:user:#{ id }:counters", transactions.bucket, transactions.amount
        Recognition.backend.zadd "recognition:user:#{ id }:transactions", hash, { amount: transactions.amount, bucket: transactions.bucket, datetime: DateTime.now.to_s }.to_json
        Recognition.backend.zadd 'recognition:transactions', hash, { id: id, amount: transactions.amount, bucket: transactions.bucket, datetime: DateTime.now.to_s }.to_json
      end
    end
    
    def self.get key
      Recognition.backend.get key
    end
    
    def self.get_user_points id
      get_user_counter id, 'points'
    end
    
    def self.get_user_counter id, counter
      counter = Recognition.backend.hget("recognition:user:#{ id }:counters", counter)
      counter.to_i
    end
    
    
    def self.update_points object, action, condition
      if condition[:bucket].nil?
        bucket = "#{ object.class.to_s.camelize }:#{ action }"
      else
        bucket = condition[:bucket]
      end
      user = parse_user(object, condition)
      if condition[:amount].nil? && condition[:gain].nil? && condition[:loss].nil?
        false
      else
        total = parse_amount(condition[:amount], object) + parse_amount(condition[:gain], object) - parse_amount(condition[:loss], object)
        ground_total = user.recognition_counter(bucket) + total
        if condition[:maximum].nil? || ground_total <= condition[:maximum]
          Database.log(user.id, total.to_i, bucket)
        end
      end
    end
    
    def self.parse_user object, condition
      if condition[:recognizable].nil?
        user = object
      else
        case condition[:recognizable].class.to_s
        when 'Symbol'
          user = object.send(condition[:recognizable])
        when 'String'
          user = object.send(condition[:recognizable].to_sym)
        when 'Proc'
          user = object.call(condition[:proc_params])
        else
          user = condition[:recognizable]
        end
      end
      user
    end
    
    def self.parse_amount amount, object
      case amount.class.to_s
      when 'Integer'
      when 'Fixnum'
        value = amount
      when 'Symbol'
        value = object.send(amount)
      when 'Proc'
        value = amount.call(object)
      when 'NilClass'
        # Do not complain about nil amounts
      else
        raise ArgumentError, "type mismatch for amount: expecting 'Integer', 'Fixnum', 'Symbol' or 'Proc' but got '#{ amount.class.to_s }' instead."
      end
      value || 0
    end
  end
end