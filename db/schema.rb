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

ActiveRecord::Schema.define(version: 2021_04_03_144414) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "unaccent"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "blockers", force: :cascade do |t|
    t.datetime "start_time", null: false
    t.datetime "end_time", null: false
    t.text "notes", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "franchise_id", null: false
    t.bigint "room_id", null: false
    t.boolean "blocking", default: true
    t.boolean "global", default: false
    t.bigint "blocker_id"
    t.index ["blocker_id"], name: "index_blockers_on_blocker_id"
    t.index ["franchise_id"], name: "index_blockers_on_franchise_id"
    t.index ["room_id"], name: "index_blockers_on_room_id"
    t.index ["user_id"], name: "index_blockers_on_user_id"
  end

  create_table "business_hours", force: :cascade do |t|
    t.bigint "franchise_id", null: false
    t.string "day", null: false
    t.time "morning_start_time", null: false
    t.time "morning_end_time", null: false
    t.time "afternoon_start_time", null: false
    t.time "afternoon_end_time", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["franchise_id"], name: "index_business_hours_on_franchise_id"
  end

  create_table "campaign_templates", force: :cascade do |t|
    t.bigint "franchise_id", null: false
    t.integer "external_id", null: false
    t.text "name", null: false
    t.text "subject", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "html", null: false
    t.index ["external_id"], name: "index_campaign_templates_on_external_id", unique: true
    t.index ["franchise_id"], name: "index_campaign_templates_on_franchise_id"
  end

  create_table "campaigns", force: :cascade do |t|
    t.string "name", null: false
    t.text "body", null: false
    t.string "recipients", array: true
    t.boolean "sms", null: false
    t.boolean "draft", default: true, null: false
    t.bigint "franchise_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.json "filters"
    t.integer "sendinblue_list_id"
    t.integer "sendinblue_campaign_id"
    t.bigint "campaign_template_id"
    t.index ["campaign_template_id"], name: "index_campaigns_on_campaign_template_id"
    t.index ["franchise_id"], name: "index_campaigns_on_franchise_id"
  end

  create_table "clients", force: :cascade do |t|
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.boolean "male", null: false
    t.bigint "franchise_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "email", null: false
    t.string "phone"
    t.string "objectives", default: [], array: true
    t.text "address"
    t.string "zip_code"
    t.string "city"
    t.string "password_digest"
    t.boolean "newsletter"
    t.datetime "last_logged_at"
    t.bigint "client_id"
    t.bigint "user_id"
    t.date "birth_date"
    t.index ["client_id"], name: "index_clients_on_client_id"
    t.index ["franchise_id"], name: "index_clients_on_franchise_id"
    t.index ["user_id"], name: "index_clients_on_user_id"
  end

  create_table "comments", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "client_id", null: false
    t.text "body", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["client_id"], name: "index_comments_on_client_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "companies", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "phone", null: false
    t.text "address", null: false
    t.string "zip_code", null: false
    t.string "city", null: false
    t.string "siret", null: false
    t.text "comment"
    t.bigint "franchise_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["franchise_id"], name: "index_companies_on_franchise_id"
  end

  create_table "company_clients", force: :cascade do |t|
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "email", null: false
    t.string "job"
    t.string "phone"
    t.bigint "company_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "password_digest"
    t.datetime "last_logged_at"
    t.bigint "company_client_id"
    t.boolean "male"
    t.string "objectives", default: [], array: true
    t.text "address"
    t.string "zip_code"
    t.string "city"
    t.boolean "boolean"
    t.date "birth_date"
    t.boolean "newsletter"
    t.index ["company_client_id"], name: "index_company_clients_on_company_client_id"
    t.index ["company_id"], name: "index_company_clients_on_company_id"
  end

  create_table "coupons", force: :cascade do |t|
    t.string "name", null: false
    t.integer "value", null: false
    t.string "code", null: false
    t.boolean "percentage", null: false
    t.date "start_date"
    t.date "end_date"
    t.integer "usage_limit"
    t.integer "usage_limit_per_person"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "male"
    t.string "objectives", array: true
    t.string "product_ids", array: true
    t.boolean "new_client", default: false
    t.boolean "loyalty", default: false
    t.bigint "client_id"
    t.bigint "company_client_id"
    t.index ["client_id"], name: "index_coupons_on_client_id"
    t.index ["company_client_id"], name: "index_coupons_on_company_client_id"
  end

  create_table "coupons_franchises", force: :cascade do |t|
    t.bigint "coupon_id", null: false
    t.bigint "franchise_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["coupon_id", "franchise_id"], name: "index_coupons_franchises_on_coupon_id_and_franchise_id", unique: true
    t.index ["coupon_id"], name: "index_coupons_franchises_on_coupon_id"
    t.index ["franchise_id"], name: "index_coupons_franchises_on_franchise_id"
  end

  create_table "credits", force: :cascade do |t|
    t.bigint "client_id"
    t.bigint "product_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "company_client_id"
    t.index ["client_id"], name: "index_credits_on_client_id"
    t.index ["company_client_id"], name: "index_credits_on_company_client_id"
    t.index ["product_id"], name: "index_credits_on_product_id"
  end

  create_table "external_products", force: :cascade do |t|
    t.bigint "franchise_id", null: false
    t.string "name", null: false
    t.integer "amount", null: false
    t.float "tax_rate", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["franchise_id"], name: "index_external_products_on_franchise_id"
  end

  create_table "franchises", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "banking_provider"
    t.text "banking_secret_key"
    t.text "banking_secret_id"
    t.string "email"
    t.text "address"
    t.string "zip_code"
    t.string "city"
    t.string "siret"
    t.string "tax_id"
    t.string "iban"
    t.string "phone"
    t.text "instagram_username"
    t.text "facebook_chat_snippet"
    t.text "sendinblue_api_key"
    t.index ["name"], name: "index_franchises_on_name", unique: true
  end

  create_table "payments", force: :cascade do |t|
    t.bigint "client_id"
    t.integer "amount", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "bank_name"
    t.string "transaction_id"
    t.bigint "coupon_id"
    t.boolean "as_paid"
    t.string "product_name", null: false
    t.string "mode"
    t.float "tax_rate", default: 20.0
    t.bigint "company_client_id"
    t.index ["client_id"], name: "index_payments_on_client_id"
    t.index ["company_client_id"], name: "index_payments_on_company_client_id"
    t.index ["coupon_id"], name: "index_payments_on_coupon_id"
  end

  create_table "product_prices", force: :cascade do |t|
    t.integer "session_count", null: false
    t.float "total", null: false
    t.boolean "professionnal", null: false
    t.bigint "product_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "first_time", default: false, null: false
    t.index ["product_id"], name: "index_product_prices_on_product_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "name", null: false
    t.text "description", null: false
    t.integer "duration", null: false
    t.bigint "room_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "active", default: true
    t.index ["room_id"], name: "index_products_on_room_id"
  end

  create_table "reservations", force: :cascade do |t|
    t.datetime "start_time"
    t.boolean "email_notification", null: false
    t.boolean "first_time", null: false
    t.bigint "client_id"
    t.bigint "product_price_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "company_client_id"
    t.bigint "payment_id"
    t.boolean "canceled", default: false, null: false
    t.text "cancelation_reason"
    t.boolean "refunded", default: false, null: false
    t.boolean "paid_by_credit", default: false, null: false
    t.text "notes"
    t.bigint "user_id"
    t.text "signature"
    t.boolean "to_be_paid_online", null: false
    t.index ["client_id"], name: "index_reservations_on_client_id"
    t.index ["company_client_id"], name: "index_reservations_on_company_client_id"
    t.index ["payment_id"], name: "index_reservations_on_payment_id"
    t.index ["product_price_id"], name: "index_reservations_on_product_price_id"
    t.index ["user_id"], name: "index_reservations_on_user_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.text "body", null: false
    t.boolean "published"
    t.bigint "product_id", null: false
    t.bigint "client_id"
    t.bigint "company_client_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "homepage"
    t.index ["client_id"], name: "index_reviews_on_client_id"
    t.index ["company_client_id"], name: "index_reviews_on_company_client_id"
    t.index ["product_id"], name: "index_reviews_on_product_id"
  end

  create_table "rooms", force: :cascade do |t|
    t.string "name", null: false
    t.integer "capacity", null: false
    t.bigint "franchise_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["franchise_id"], name: "index_rooms_on_franchise_id"
  end

  create_table "subscription_plans", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.integer "session_count", null: false
    t.float "total", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["product_id"], name: "index_subscription_plans_on_product_id"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.bigint "subscription_plan_id", null: false
    t.bigint "client_id", null: false
    t.string "external_id"
    t.string "status", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "to_be_canceled_at"
    t.index ["client_id"], name: "index_subscriptions_on_client_id"
    t.index ["subscription_plan_id", "client_id"], name: "index_subscriptions_on_subscription_plan_id_and_client_id", unique: true
    t.index ["subscription_plan_id"], name: "index_subscriptions_on_subscription_plan_id"
  end

  create_table "survey_questions", force: :cascade do |t|
    t.bigint "survey_id", null: false
    t.text "body", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["survey_id"], name: "index_survey_questions_on_survey_id"
  end

  create_table "surveys", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["product_id"], name: "index_surveys_on_product_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.bigint "franchise_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "superuser", default: false, null: false
    t.datetime "last_logged_at"
    t.string "password_digest"
    t.boolean "nutritionist", default: false, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["franchise_id"], name: "index_users_on_franchise_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "blockers", "blockers"
  add_foreign_key "blockers", "franchises"
  add_foreign_key "blockers", "rooms"
  add_foreign_key "blockers", "users"
  add_foreign_key "business_hours", "franchises"
  add_foreign_key "campaign_templates", "franchises"
  add_foreign_key "campaigns", "campaign_templates"
  add_foreign_key "campaigns", "franchises"
  add_foreign_key "clients", "clients"
  add_foreign_key "clients", "franchises"
  add_foreign_key "clients", "users"
  add_foreign_key "comments", "clients"
  add_foreign_key "comments", "users"
  add_foreign_key "companies", "franchises"
  add_foreign_key "company_clients", "companies"
  add_foreign_key "company_clients", "company_clients"
  add_foreign_key "coupons", "clients"
  add_foreign_key "coupons", "company_clients"
  add_foreign_key "coupons_franchises", "coupons"
  add_foreign_key "coupons_franchises", "franchises"
  add_foreign_key "credits", "clients"
  add_foreign_key "credits", "company_clients"
  add_foreign_key "credits", "products"
  add_foreign_key "payments", "clients"
  add_foreign_key "payments", "company_clients"
  add_foreign_key "payments", "coupons"
  add_foreign_key "product_prices", "products"
  add_foreign_key "products", "rooms"
  add_foreign_key "reservations", "clients"
  add_foreign_key "reservations", "company_clients"
  add_foreign_key "reservations", "payments"
  add_foreign_key "reservations", "product_prices"
  add_foreign_key "reservations", "users"
  add_foreign_key "reviews", "clients"
  add_foreign_key "reviews", "company_clients"
  add_foreign_key "reviews", "products"
  add_foreign_key "rooms", "franchises"
  add_foreign_key "subscription_plans", "products"
  add_foreign_key "subscriptions", "clients"
  add_foreign_key "subscriptions", "subscription_plans"
  add_foreign_key "survey_questions", "surveys"
  add_foreign_key "surveys", "products"
  add_foreign_key "users", "franchises"
end
