class CreateCatalogBookListings < ActiveRecord::Migration[8.1]
  def change
    create_table :catalog_book_listings, id: :string do |t|
      t.string :book_id, null: false
      t.string :title, null: false
      t.string :author_name
      t.string :category_name
      t.string :isbn
      t.integer :price_cents
      t.string :currency, default: "USD"
      t.integer :stock_available, default: 0
      t.string :status, default: "active"
      t.timestamps
    end
    add_index :catalog_book_listings, :book_id, unique: true
  end
end
