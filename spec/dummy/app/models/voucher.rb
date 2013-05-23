class Voucher < ActiveRecord::Base
  acts_as_voucher code_length: 14, suffix: 'XYZ', prefix: -> voucher { voucher.amount }
  
  attr_accessible :amount, :code, :expires_at, :reusable
  
  validates_voucher_redmeption [:my_custom_validator, :another_custom_validator]
  
  def my_custom_validator
    # only allow vouchers less than 10000
    amount < 10000
  end
  
  def another_custom_validator
    # DO NOT allow vouchers exactly equal to 1000
    amount != 1000
  end
end
