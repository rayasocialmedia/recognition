class CreateGifts < ActiveRecord::Migration
  def change
    create_table :gifts do |t|
      t.string :code
      t.integer :amount
      t.boolean :reusable, default: false
      t.datetime :expires_at

      t.timestamps
    end
  end
end
