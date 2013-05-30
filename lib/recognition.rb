require "recognition/version"
require "recognition/rails/engine"
require "recognition/rails/railtie"
require "redis"

module Recognition
  mattr_accessor :redis
  # Redis Db connection parameters
  @@redis = 'localhost:6378'

  mattr_accessor :debug
  # Show debugging messages in log
  @@debug = false

  mattr_accessor :logger
  # Set logger class
  @@logger = ::Logger.new(STDOUT)

  mattr_accessor :backend
  # Redis Db active connection
  @@backend = nil
  
  # Initialize recognition
  def self.setup
    yield self
  end
  
  def self.log key, message
    Recognition.logger.info("[recognition] [#{key}] #{message}") if Recognition.debug
  end
  
  # Connect to Redis Db
  def self.backend
    if self.redis['redis://']
      @@backend = Redis.connect(:url => self.redis, :thread_safe => true)
    else
      self.redis, namespace = self.redis.split('/', 2)
      host, port, db = self.redis.split(':')

      @@backend = Redis.new(
        :host => host,
        :port => port,
        :db => db,
        :thread_safe => true
      )
    end
  end
end
