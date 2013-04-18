require "recognition/transaction"

module Recognition
  module Database
    def self.log id, amount, bucket
      hash = Time.now.to_f.to_s
      $REDIS.multi do
        # $REDIS.incrby "recognition:user:#{ id }:points", amount
        $REDIS.hincrby "recognition:user:#{ id }:counters", 'points', amount
        $REDIS.hincrby "recognition:user:#{ id }:counters", bucket, amount
        $REDIS.zadd "recognition:user:#{ id }:transactions", hash, { amount: amount, bucket: bucket, datetime: DateTime.now.to_s }.to_json
        $REDIS.zadd 'recognition:transactions', hash, { id: id, amount: amount, bucket: bucket, datetime: DateTime.now.to_s }.to_json
      end
    end
    
    def self.record transaction
      unless transaction.class.to_s == Recognition::Transaction
        raise ArgumentError, 'parameter should be of type Recognition::Transaction'
      end
      hash = Time.now.to_f.to_s
      $REDIS.multi do
        # $REDIS.incrby "recognition:user:#{ id }:points", amount
        $REDIS.hincrby "recognition:user:#{ id }:counters", 'points', transactions.amount
        $REDIS.hincrby "recognition:user:#{ id }:counters", transactions.bucket, transactions.amount
        $REDIS.zadd "recognition:user:#{ id }:transactions", hash, { amount: transactions.amount, bucket: transactions.bucket, datetime: DateTime.now.to_s }.to_json
        $REDIS.zadd 'recognition:transactions', hash, { id: id, amount: transactions.amount, bucket: transactions.bucket, datetime: DateTime.now.to_s }.to_json
      end
    end
    
    def self.get key
      $REDIS.get key
    end
    
    def self.get_user_points id
      get_user_counter id, 'points'
    end
    
    def self.get_user_counter id, counter
      counter = $REDIS.hget("recognition:user:#{ id }:counters", counter)
      counter.to_i
    end
    
    
    def self.add_points object, action, condition
      bucket = "M:#{ object.class.to_s.camelize }:#{ action }"
      user = parse_user(object, condition)
      total = parse_amount(condition[:amount]) + parse_amount(condition[:gain]) - parse_amount(condition[:loss])
      ground_total = user.recognition_counter(bucket) + total
      if condition[:maximum].nil? || ground_total <= condition[:maximum]
        Database.log(user.id, total, bucket)
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
    
    def self.parse_amount amount
      case amount.class.to_s
      when 'Integer'
      when 'Fixnum'
        value = amount
      when 'Symbol'
        value = object.send(amount)
      when 'NilClass'
        # Do not complain about nil amounts
      else
        raise ArgumentError, "type mismatch for amount: expecting 'Integer', 'Fixnum' or 'Symbol', got '#{ amount.class.to_s }'"
      end
      value || 0
    end
  end
end