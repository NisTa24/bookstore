# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_03_28_000011) do
  create_table "catalog_authors", id: :string, force: :cascade do |t|
    t.text "biography"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
  end

  create_table "catalog_book_listings", id: :string, force: :cascade do |t|
    t.string "author_name"
    t.string "book_id", null: false
    t.string "category_name"
    t.datetime "created_at", null: false
    t.string "currency", default: "USD"
    t.string "isbn"
    t.integer "price_cents"
    t.string "status", default: "active"
    t.integer "stock_available", default: 0
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["book_id"], name: "index_catalog_book_listings_on_book_id", unique: true
  end

  create_table "catalog_books", id: :string, force: :cascade do |t|
    t.string "author_id"
    t.string "category_id"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "isbn", null: false
    t.string "status", default: "active", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_catalog_books_on_author_id"
    t.index ["category_id"], name: "index_catalog_books_on_category_id"
    t.index ["isbn"], name: "index_catalog_books_on_isbn", unique: true
    t.index ["status"], name: "index_catalog_books_on_status"
  end

  create_table "catalog_categories", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_catalog_categories_on_slug", unique: true
  end

  create_table "domain_events_log", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "event_type", null: false
    t.datetime "occurred_at", null: false
    t.json "payload", default: {}, null: false
    t.string "source_command"
    t.datetime "updated_at", null: false
    t.index ["event_type"], name: "index_domain_events_log_on_event_type"
    t.index ["occurred_at"], name: "index_domain_events_log_on_occurred_at"
  end

  create_table "inventory_stock_items", id: :string, force: :cascade do |t|
    t.string "book_id", null: false
    t.datetime "created_at", null: false
    t.integer "quantity_on_hand", default: 0, null: false
    t.integer "quantity_reserved", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["book_id"], name: "index_inventory_stock_items_on_book_id", unique: true
  end

  create_table "ordering_order_lines", id: :string, force: :cascade do |t|
    t.string "book_id", null: false
    t.datetime "created_at", null: false
    t.string "order_id", null: false
    t.integer "quantity", null: false
    t.integer "unit_price_cents", null: false
    t.string "unit_price_currency", default: "USD", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_ordering_order_lines_on_order_id"
  end

  create_table "ordering_order_summaries", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "currency", default: "USD", null: false
    t.string "customer_email", null: false
    t.integer "item_count", default: 0, null: false
    t.string "order_id", null: false
    t.string "order_number", null: false
    t.string "status", null: false
    t.integer "total_amount_cents", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_ordering_order_summaries_on_order_id", unique: true
    t.index ["order_number"], name: "index_ordering_order_summaries_on_order_number", unique: true
  end

  create_table "ordering_orders", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "customer_email", null: false
    t.string "order_number", null: false
    t.string "status", default: "pending", null: false
    t.integer "total_amount_cents", default: 0, null: false
    t.string "total_currency", default: "USD", null: false
    t.datetime "updated_at", null: false
    t.index ["order_number"], name: "index_ordering_orders_on_order_number", unique: true
    t.index ["status"], name: "index_ordering_orders_on_status"
  end

  create_table "pricing_discount_rules", id: :string, force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "book_id"
    t.string "category_id"
    t.datetime "created_at", null: false
    t.string "discount_type", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.datetime "valid_from", null: false
    t.datetime "valid_until"
    t.integer "value", null: false
  end

  create_table "pricing_prices", id: :string, force: :cascade do |t|
    t.integer "amount_cents", null: false
    t.string "book_id", null: false
    t.datetime "created_at", null: false
    t.string "currency", default: "USD", null: false
    t.datetime "effective_from", null: false
    t.datetime "effective_until"
    t.datetime "updated_at", null: false
    t.index ["book_id", "effective_from"], name: "index_pricing_prices_on_book_id_and_effective_from"
  end
end
