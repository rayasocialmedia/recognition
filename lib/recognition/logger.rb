require 'logger'

module Recognition
  module Logger
    def log key, message
      logger.info("[recognition] [#{key}] #{message}") if logging?
    end

    def logger #:nodoc:
      @logger ||= ::Logger.new(STDOUT)
    end

    def logger=(logger)
      @logger = logger
    end

    def logging? #:nodoc:
      # TODO: Add an option to toggle logging
      false
    end
  end
end