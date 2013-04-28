class User < ActiveRecord::Base
  attr_accessible :name
  has_many :posts
  
  acts_as_recognizable initial: 5
end
