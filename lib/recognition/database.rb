require 'recognition/parser'

module Recognition
  # Handle all Transactions and logging to Redis
  module Database
    def self.log id, amount, bucket, code = nil
      hash = Time.now.to_f.to_s
      Recognition.backend.multi do
        Recognition.backend.hincrby "recognition:user:#{ id }:counters", 'points', amount
        Recognition.backend.hincrby "recognition:user:#{ id }:counters", bucket, amount
        Recognition.backend.zadd "recognition:user:#{ id }:transactions", hash, { hash: hash, amount: amount, bucket: bucket, datetime: DateTime.now.to_s }.to_json
        Recognition.backend.zadd 'recognition:transactions', hash, { hash: hash, id: id, amount: amount, bucket: bucket, datetime: DateTime.now.to_s }.to_json
        unless code.nil?
          Recognition.backend.zadd "recognition:voucher:#{ code }:transactions", hash, { hash: hash, id: id, bucket: bucket, datetime: DateTime.now.to_s }.to_json
        end
      end
    end
    
    def self.get key
      Recognition.backend.get "recognition:#{key}"
    end
    
    def self.get_counter hash, key
      Recognition.backend.hget("recognition:#{hash}", key).to_i
    end
    
    def self.update_points object, action, condition
      if condition[:bucket].nil?
        bucket = "#{ object.class.to_s.camelize }:#{ action }"
      else
        bucket = condition[:bucket]
      end
      user = Recognition::Parser.parse_recognizable(object, condition[:recognizable])
      if condition[:amount].nil? && condition[:gain].nil? && condition[:loss].nil?
        false
      else
        total = Recognition::Parser.parse_amount(condition[:amount], object) + Recognition::Parser.parse_amount(condition[:gain], object) - Recognition::Parser.parse_amount(condition[:loss], object)
        ground_total = user.recognition_counter(bucket) + total
        if condition[:maximum].nil? || ground_total <= condition[:maximum]
          Database.log(user.id, total.to_i, bucket)
        end
      end
    end
    
    private
    
    def self.get_transactions keypart, start, stop
      transactions = []
      range = Recognition.backend.zrange "recognition:#{ keypart }:transactions", start, stop
      range.each do |transaction|
        transactions << JSON.parse(transaction, { symbolize_names: true })
      end
      transactions
    end
  end
end