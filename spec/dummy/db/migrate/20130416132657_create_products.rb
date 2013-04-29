class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :name
      t.integer :points
      t.belongs_to :owner
      t.belongs_to :buyer

      t.timestamps
    end
    add_index :products, :owner_id
    add_index :products, :buyer_id
  end
end
