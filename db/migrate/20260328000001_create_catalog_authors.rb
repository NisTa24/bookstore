class CreateCatalogAuthors < ActiveRecord::Migration[8.1]
  def change
    create_table :catalog_authors, id: :string do |t|
      t.string :name, null: false
      t.text :biography
      t.timestamps
    end
  end
end
