class User < ActiveRecord::Base
  attr_accessible :name
  has_many :posts
  has_many :products
  
  acts_as_recognizable initial: 5
end
