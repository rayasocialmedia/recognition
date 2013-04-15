module Recognition
  module Condition
    def parse opts
      {
        opts[:for] => {
          recognizable: nil,
          amount: options[:initial]
        }
      }
    end
  end
end