class Voucher < ActiveRecord::Base
  acts_as_voucher code_length: 14 

  attr_accessible :amount, :code, :expires_at, :reusable
end
