class CreateVouchers < ActiveRecord::Migration
  def change
    create_table :vouchers do |t|
      t.string :code
      t.string :amount
      t.boolean :reusable
      t.datetime :expires_at

      t.timestamps
    end
  end
end
