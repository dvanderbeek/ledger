# encoding: UTF-8
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
ActiveRecord::Schema.define(version: 20160401184328) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "type"
  end

  create_table "entries", force: :cascade do |t|
    t.integer  "account_id"
    t.decimal  "amount_cents"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "type"
    t.string   "product_uuid"
    t.integer  "txn_id"
    t.date     "date"
  end

  add_index "entries", ["account_id"], name: "index_entries_on_account_id", using: :btree
  add_index "entries", ["date"], name: "index_entries_on_date", using: :btree
  add_index "entries", ["product_uuid"], name: "index_entries_on_product_uuid", using: :btree
  add_index "entries", ["txn_id"], name: "index_entries_on_txn_id", using: :btree

  create_table "txns", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.date     "date"
    t.string   "product_uuid"
    t.integer  "parent_id"
    t.string   "type"
  end

  add_index "txns", ["date"], name: "index_txns_on_date", using: :btree
  add_index "txns", ["parent_id"], name: "index_txns_on_parent_id", using: :btree
  add_index "txns", ["product_uuid"], name: "index_txns_on_product_uuid", using: :btree

  add_foreign_key "entries", "accounts"
  add_foreign_key "entries", "txns"
end
