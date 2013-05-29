module Recognition
  module Parser
    def self.parse_recognizable object, recognizable, proc_params = nil
      if recognizable.nil?
        user = object
      else
        case recognizable.class.to_s
        when 'Symbol'
          user = object.send(recognizable)
        when 'String'
          user = object.send(recognizable.to_sym)
        when 'Proc'
          params = proc_params || object
          user = recognizable.call(params)
        else
          user = recognizable
        end
      end
      user
    end
    
    def self.parse_amount amount, object, proc_params = nil
      case amount.class.to_s
      when 'Integer'
        value = amount
      when 'Fixnum'
        value = amount
      when 'Symbol'
        value = object.send(amount)
      when 'Proc'
        params = proc_params || object
        value = amount.call(params)
      when 'NilClass'
        # Do not complain about nil amounts
      else
        raise ArgumentError, "type mismatch for amount: expecting 'Integer', 'Fixnum', 'Symbol' or 'Proc' but got '#{ amount.class.to_s }' instead."
      end
      value || 0
    end
    
    def self.parse_code_part part, object
      case part.class.to_s
      when 'String'
        value = part
      when 'Integer'
        value = part.to_s
      when 'Fixnum'
        value = part.to_s
      when 'Symbol'
        value = object.send(part).to_s
      when 'Proc'
        value = part.call(object).to_s
      when 'NilClass'
        # Do not complain about nil amounts
      else
        raise ArgumentError, "type mismatch for voucher part: expecting 'Integer', 'Fixnum', 'Symbol' or 'Proc' but got '#{ amount.class.to_s }' instead."
      end
      value || ''
    end
    
  end
end