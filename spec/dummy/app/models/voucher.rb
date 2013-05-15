class Voucher < ActiveRecord::Base
  attr_accessible :amount, :code, :expires_at, :reusable
  acts_as_voucher code_length: 14
end
