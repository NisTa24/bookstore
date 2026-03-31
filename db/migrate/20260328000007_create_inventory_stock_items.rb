class CreateInventoryStockItems < ActiveRecord::Migration[8.1]
  def change
    create_table :inventory_stock_items, id: :string do |t|
      t.string :book_id, null: false
      t.integer :quantity_on_hand, null: false, default: 0
      t.integer :quantity_reserved, null: false, default: 0
      t.timestamps
    end
    add_index :inventory_stock_items, :book_id, unique: true
  end
end
