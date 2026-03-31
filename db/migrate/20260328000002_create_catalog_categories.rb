class CreateCatalogCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :catalog_categories, id: :string do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.timestamps
    end
    add_index :catalog_categories, :slug, unique: true
  end
end
