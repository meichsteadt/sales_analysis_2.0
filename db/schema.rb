# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180730235406) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "customer_groups", force: :cascade do |t|
    t.integer "customer_id"
    t.integer "group_id"
    t.string  "number"
    t.string  "name"
    t.string  "category"
    t.decimal "sales_year"
    t.decimal "prev_sales_year"
    t.decimal "sales_ytd"
    t.decimal "prev_sales_ytd"
    t.decimal "growth"
    t.integer "quantity",            default: 0
    t.integer "prev_quantity",       default: 0
    t.integer "quantity_ytd",        default: 0
    t.integer "prev_quantity_ytd",   default: 0
    t.integer "quantity_growth",     default: 0
    t.integer "quantity_growth_ytd", default: 0
    t.decimal "growth_ytd",          default: "0.0"
    t.index ["customer_id"], name: "index_customer_groups_on_customer_id", using: :btree
    t.index ["group_id"], name: "index_customer_groups_on_group_id", using: :btree
  end

  create_table "customer_products", force: :cascade do |t|
    t.integer "customer_id"
    t.integer "product_id"
    t.string  "number"
    t.string  "name"
    t.decimal "sales_year"
    t.decimal "prev_sales_year"
    t.decimal "sales_ytd"
    t.decimal "prev_sales_ytd"
    t.decimal "growth"
    t.integer "quantity",            default: 0
    t.integer "prev_quantity",       default: 0
    t.integer "quantity_ytd",        default: 0
    t.integer "prev_quantity_ytd",   default: 0
    t.integer "quantity_growth",     default: 0
    t.integer "quantity_growth_ytd", default: 0
    t.decimal "growth_ytd",          default: "0.0"
    t.index ["customer_id"], name: "index_customer_products_on_customer_id", using: :btree
    t.index ["product_id"], name: "index_customer_products_on_product_id", using: :btree
  end

  create_table "customers", force: :cascade do |t|
    t.string   "name"
    t.integer  "user_id"
    t.string   "name_id"
    t.string   "state"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.decimal  "sales_year"
    t.decimal  "prev_sales_year"
    t.decimal  "sales_ytd"
    t.decimal  "prev_sales_ytd"
    t.decimal  "growth"
    t.integer  "quantity",            default: 0
    t.integer  "prev_quantity",       default: 0
    t.integer  "quantity_ytd",        default: 0
    t.integer  "prev_quantity_ytd",   default: 0
    t.integer  "quantity_growth",     default: 0
    t.integer  "quantity_growth_ytd", default: 0
    t.decimal  "growth_ytd",          default: "0.0"
    t.index ["user_id"], name: "index_customers_on_user_id", using: :btree
  end

  create_table "groups", force: :cascade do |t|
    t.string   "number"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "category"
    t.string   "image"
    t.integer  "age"
    t.decimal  "sales_year"
    t.decimal  "prev_sales_year"
    t.decimal  "sales_ytd"
    t.decimal  "prev_sales_ytd"
    t.decimal  "growth"
    t.integer  "quantity",            default: 0
    t.integer  "prev_quantity",       default: 0
    t.integer  "quantity_ytd",        default: 0
    t.integer  "prev_quantity_ytd",   default: 0
    t.integer  "quantity_growth",     default: 0
    t.integer  "quantity_growth_ytd", default: 0
    t.decimal  "growth_ytd",          default: "0.0"
  end

  create_table "notes", force: :cascade do |t|
    t.string   "numberable_type"
    t.integer  "numberable_id"
    t.text     "note"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["numberable_type", "numberable_id"], name: "index_notes_on_numberable_type_and_numberable_id", using: :btree
  end

  create_table "orders", force: :cascade do |t|
    t.integer  "customer_id"
    t.string   "invoice_id"
    t.date     "invoice_date"
    t.integer  "quantity",     default: 0
    t.boolean  "promo"
    t.integer  "user_id"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.integer  "product_id"
    t.decimal  "total"
    t.decimal  "price"
    t.index ["customer_id"], name: "index_orders_on_customer_id", using: :btree
    t.index ["product_id"], name: "index_orders_on_product_id", using: :btree
    t.index ["user_id"], name: "index_orders_on_user_id", using: :btree
  end

  create_table "products", force: :cascade do |t|
    t.string   "category"
    t.string   "number"
    t.integer  "group_id"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.float    "price"
    t.string   "image"
    t.float    "promo_price"
    t.integer  "age"
    t.decimal  "sales_year"
    t.decimal  "prev_sales_year"
    t.decimal  "sales_ytd"
    t.decimal  "prev_sales_ytd"
    t.decimal  "growth"
    t.integer  "quantity",            default: 0
    t.integer  "prev_quantity",       default: 0
    t.integer  "quantity_ytd",        default: 0
    t.integer  "prev_quantity_ytd",   default: 0
    t.integer  "quantity_growth",     default: 0
    t.integer  "quantity_growth_ytd", default: 0
    t.decimal  "growth_ytd",          default: "0.0"
  end

  create_table "sales_numbers", force: :cascade do |t|
    t.string  "numberable_type"
    t.integer "numberable_id"
    t.integer "month"
    t.integer "year"
    t.integer "user_id"
    t.decimal "sales"
    t.integer "quantity",        default: 0
    t.index ["numberable_type", "numberable_id"], name: "index_sales_numbers_on_numberable_type_and_numberable_id", using: :btree
  end

  create_table "user_groups", force: :cascade do |t|
    t.integer "user_id"
    t.integer "group_id"
    t.string  "number"
    t.string  "category"
    t.decimal "sales_year"
    t.decimal "prev_sales_year"
    t.decimal "sales_ytd"
    t.decimal "prev_sales_ytd"
    t.decimal "growth"
    t.integer "quantity",            default: 0
    t.integer "prev_quantity",       default: 0
    t.integer "quantity_ytd",        default: 0
    t.integer "prev_quantity_ytd",   default: 0
    t.integer "quantity_growth",     default: 0
    t.integer "quantity_growth_ytd", default: 0
    t.decimal "growth_ytd",          default: "0.0"
    t.index ["group_id"], name: "index_user_groups_on_group_id", using: :btree
    t.index ["user_id"], name: "index_user_groups_on_user_id", using: :btree
  end

  create_table "user_products", force: :cascade do |t|
    t.integer "user_id"
    t.integer "product_id"
    t.string  "number"
    t.decimal "sales_year"
    t.decimal "prev_sales_year"
    t.decimal "sales_ytd"
    t.decimal "prev_sales_ytd"
    t.decimal "growth"
    t.integer "quantity",            default: 0
    t.integer "prev_quantity",       default: 0
    t.integer "quantity_ytd",        default: 0
    t.integer "prev_quantity_ytd",   default: 0
    t.integer "quantity_growth",     default: 0
    t.integer "quantity_growth_ytd", default: 0
    t.decimal "growth_ytd",          default: "0.0"
    t.index ["product_id"], name: "index_user_products_on_product_id", using: :btree
    t.index ["user_id"], name: "index_user_products_on_user_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "email"
    t.string   "password_digest"
    t.string   "rep_ids",             default: [],                 array: true
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.decimal  "sales_year"
    t.decimal  "prev_sales_year"
    t.decimal  "sales_ytd"
    t.decimal  "prev_sales_ytd"
    t.decimal  "growth"
    t.integer  "quantity",            default: 0
    t.integer  "prev_quantity",       default: 0
    t.integer  "quantity_ytd",        default: 0
    t.integer  "prev_quantity_ytd",   default: 0
    t.integer  "quantity_growth",     default: 0
    t.integer  "quantity_growth_ytd", default: 0
    t.decimal  "growth_ytd",          default: "0.0"
  end

end
