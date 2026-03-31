class CreatePricingDiscountRules < ActiveRecord::Migration[8.1]
  def change
    create_table :pricing_discount_rules, id: :string do |t|
      t.string :name, null: false
      t.string :discount_type, null: false
      t.integer :value, null: false
      t.string :book_id
      t.string :category_id
      t.datetime :valid_from, null: false
      t.datetime :valid_until
      t.boolean :active, null: false, default: true
      t.timestamps
    end
  end
end
