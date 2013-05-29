class Gift < ActiveRecord::Base
  acts_as_gift code_length: 20 

  attr_accessible :amount, :code, :expires_at, :reusable

  validates_gift_redmeption :my_custom_validator
  
  def my_custom_validator
    # only allow vouchers less than 10000
    amount < 10000
  end
  
end
