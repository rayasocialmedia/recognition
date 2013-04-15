class Product < ActiveRecord::Base
  attr_accessible :name, :points
  
  recognize :user, for: :buy, loss: :points  
  
  def buy
    true
  end
end
