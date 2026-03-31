class CreateOrderingOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :ordering_orders, id: :string do |t|
      t.string :order_number, null: false
      t.string :customer_email, null: false
      t.string :status, null: false, default: "pending"
      t.integer :total_amount_cents, null: false, default: 0
      t.string :total_currency, null: false, default: "USD"
      t.timestamps
    end
    add_index :ordering_orders, :order_number, unique: true
    add_index :ordering_orders, :status
  end
end
