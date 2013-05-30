require 'recognition/parser'

module Recognition
  # Handle all Transactions and logging to Redis
  module Database
    def self.log id, amount, bucket, code = nil
      hash = Time.now.to_f.to_s
      Recognition.log :transaction, "hash:'#{hash}' user:'#{id}' amount:'#{amount}' bucket:'#{bucket}'"
      Recognition.backend.multi do
        Recognition.backend.hincrby "recognition:user:#{ id }:counters", 'points', amount
        Recognition.backend.hincrby "recognition:user:#{ id }:counters", bucket, amount
        Recognition.backend.zadd "recognition:user:#{ id }:transactions", hash, { hash: hash, amount: amount, bucket: bucket, datetime: DateTime.now.to_s }.to_json
        Recognition.backend.zadd 'recognition:transactions', hash, { hash: hash, id: id, amount: amount, bucket: bucket, datetime: DateTime.now.to_s }.to_json
        unless code.nil?
          Recognition.backend.zadd "recognition:#{ code[:type] }:#{ code[:code] }:transactions", hash, { hash: hash, id: id, bucket: bucket, datetime: DateTime.now.to_s }.to_json
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
      condition[:bucket] ||= "#{ object.class.to_s.camelize }:#{ action }"
      user = Recognition::Parser.parse_recognizable(object, condition[:recognizable], condition[:proc_params])
      # Do we have a valid user?
      if user.respond_to?(:points)
        if condition[:amount].nil? && condition[:gain].nil? && condition[:loss].nil?
          Recognition.log 'validation', "Unable to determine points: no 'amount', 'gain' or 'loss' specified"
          false
        else
          total = Recognition::Parser.parse_amount(condition[:amount], object, condition[:proc_params]) + Recognition::Parser.parse_amount(condition[:gain], object, condition[:proc_params]) - Recognition::Parser.parse_amount(condition[:loss], object, condition[:proc_params])
          ground_total = user.recognition_counter(condition[:bucket]) + total
          if condition[:maximum].nil? || ground_total <= condition[:maximum]
            log(user.id, total.to_i, condition[:bucket])
          else
            Recognition.log 'validation', "Unable to add points: bucket maximum reached for bucket '#{condition[:bucket]}'"
          end
        end
      else
        Recognition.log 'validation', "Unable to add points to #{condition[:recognizable]}, make sure it 'acts_as_recognizable'"
      end
    end
    
    def self.redeem id, bucket, type, code, value
      certificate = { type: type, code: code }
      Recognition.log type, "redeeming #{type}:#{code} for user: #{id}"
      log id, value, bucket, certificate
    end
    
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