rails_root = Rails.root || File.dirname(__FILE__) + '/../..'
rails_env = Rails.env || 'development'

Recognition.setup do |config|
  config.redis = YAML.load_file("#{ rails_root.to_s }/config/recognition.yml")[Rails.env.to_s]
  config.debug = true
end