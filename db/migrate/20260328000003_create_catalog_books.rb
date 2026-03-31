class CreateCatalogBooks < ActiveRecord::Migration[8.1]
  def change
    create_table :catalog_books, id: :string do |t|
      t.string :title, null: false
      t.string :isbn, null: false
      t.text :description
      t.string :author_id
      t.string :category_id
      t.string :status, null: false, default: "active"
      t.timestamps
    end
    add_index :catalog_books, :isbn, unique: true
    add_index :catalog_books, :status
    add_index :catalog_books, :author_id
    add_index :catalog_books, :category_id
  end
end
