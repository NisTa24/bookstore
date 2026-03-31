class CreateOrderingOrderLines < ActiveRecord::Migration[8.1]
  def change
    create_table :ordering_order_lines, id: :string do |t|
      t.string :order_id, null: false
      t.string :book_id, null: false
      t.integer :quantity, null: false
      t.integer :unit_price_cents, null: false
      t.string :unit_price_currency, null: false, default: "USD"
      t.timestamps
    end
    add_index :ordering_order_lines, :order_id
  end
end
