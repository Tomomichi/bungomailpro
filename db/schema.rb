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

ActiveRecord::Schema[8.0].define(version: 2025_01_01_000000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "btree_gist"
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "campaigns", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.integer "book_id", null: false
    t.string "book_title", null: false
    t.string "author_name", null: false
    t.date "start_date", null: false
    t.date "end_date", null: false
    t.time "delivery_time", default: "2000-01-01 07:00:00", null: false
    t.string "color", null: false
    t.string "pattern", null: false
    t.datetime "created_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.index ["book_id"], name: "index_campaigns_on_book_id"
    t.index ["end_date"], name: "index_campaigns_on_end_date"
    t.index ["start_date"], name: "index_campaigns_on_start_date"
    t.index ["user_id"], name: "index_campaigns_on_user_id"
  end

  create_table "delayed_jobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at", precision: nil
    t.datetime "locked_at", precision: nil
    t.datetime "failed_at", precision: nil
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "feeds", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "campaign_id", null: false
    t.integer "position", null: false
    t.text "content", null: false
    t.datetime "created_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.index ["campaign_id", "position"], name: "index_feeds_on_campaign_id_and_position", unique: true
    t.index ["campaign_id"], name: "index_feeds_on_campaign_id"
    t.check_constraint "\"position\" >= 1", name: "check_position_greater_than_zero"
  end

  create_table "subscriptions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "campaign_id", null: false
    t.string "delivery_method", default: "email", null: false
    t.datetime "created_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.index ["campaign_id"], name: "index_subscriptions_on_campaign_id"
    t.index ["delivery_method"], name: "index_subscriptions_on_delivery_method"
    t.index ["user_id", "campaign_id"], name: "index_subscriptions_on_user_id_and_campaign_id", unique: true
    t.index ["user_id"], name: "index_subscriptions_on_user_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email", null: false
    t.string "crypted_password"
    t.string "salt"
    t.string "stripe_customer_id"
    t.date "trial_start_date"
    t.date "trial_end_date"
    t.string "plan", default: "free", null: false
    t.string "magic_login_token"
    t.datetime "magic_login_token_expires_at", precision: nil
    t.datetime "magic_login_email_sent_at", precision: nil
    t.string "fcm_device_token"
    t.datetime "created_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["magic_login_token"], name: "index_users_on_magic_login_token"
  end

  add_foreign_key "campaigns", "users", on_delete: :cascade
  add_foreign_key "feeds", "campaigns", on_delete: :cascade
  add_foreign_key "subscriptions", "campaigns", on_delete: :cascade
  add_foreign_key "subscriptions", "users", on_delete: :cascade
end
