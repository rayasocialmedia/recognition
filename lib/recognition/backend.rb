module Recognition
  class Backend
    attr_reader :store
    
    def initialize(store)
      @store = store
    end
    
  end
end