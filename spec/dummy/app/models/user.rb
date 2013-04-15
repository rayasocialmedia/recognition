class User < ActiveRecord::Base
  attr_accessible :name
  has_many :posts
  
  acts_as_recognizeable initial: 5
end
