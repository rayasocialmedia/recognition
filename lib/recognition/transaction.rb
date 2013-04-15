module Recognition
  class Transaction
    attr_accessor :id, :gain, :loss, :bucket
    
    def create *args
      args.each do |key, val|
        self.new
      end
    end
  end
end