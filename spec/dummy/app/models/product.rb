class Product < ActiveRecord::Base
  attr_accessible :name, :points, :owner, :buyer
  
  belongs_to :owner, class_name: 'User'
  belongs_to :buyer, class_name: 'User'
  
  def buy buyer
    self.buyer = buyer
    self.save
  end

  def false_buying buyer
    false
  end

  recognize :owner, for: :create, gain: :points
  recognize :buyer, for: :buy, loss: -> product { 2 * product.points }
  recognize :owner, for: :false_buying, loss: :points
end
