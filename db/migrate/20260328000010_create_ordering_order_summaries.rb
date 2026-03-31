class CreateOrderingOrderSummaries < ActiveRecord::Migration[8.1]
  def change
    create_table :ordering_order_summaries, id: :string do |t|
      t.string :order_id, null: false
      t.string :order_number, null: false
      t.string :customer_email, null: false
      t.string :status, null: false
      t.integer :total_amount_cents, null: false
      t.string :currency, null: false, default: "USD"
      t.integer :item_count, null: false, default: 0
      t.timestamps
    end
    add_index :ordering_order_summaries, :order_id, unique: true
    add_index :ordering_order_summaries, :order_number, unique: true
  end
end
