class Post < ActiveRecord::Base
  attr_accessible :title, :user_id
  belongs_to :user
  
  recognize :user, for: :create, gain: 7
  recognize :user, for: :destroy, loss: 1, maximum: 3
end
