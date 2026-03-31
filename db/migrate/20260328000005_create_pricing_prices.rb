class CreatePricingPrices < ActiveRecord::Migration[8.1]
  def change
    create_table :pricing_prices, id: :string do |t|
      t.string :book_id, null: false
      t.integer :amount_cents, null: false
      t.string :currency, null: false, default: "USD"
      t.datetime :effective_from, null: false
      t.datetime :effective_until
      t.timestamps
    end
    add_index :pricing_prices, [:book_id, :effective_from]
  end
end
