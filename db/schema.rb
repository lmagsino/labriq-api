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

ActiveRecord::Schema[7.1].define(version: 2026_03_26_000003) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "doctor_questions", force: :cascade do |t|
    t.bigint "scan_id", null: false
    t.text "question"
    t.integer "sort_order"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["scan_id"], name: "index_doctor_questions_on_scan_id"
  end

  create_table "feedbacks", force: :cascade do |t|
    t.bigint "scan_id", null: false
    t.bigint "lab_result_id"
    t.string "feedback_type"
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lab_result_id"], name: "index_feedbacks_on_lab_result_id"
    t.index ["scan_id"], name: "index_feedbacks_on_scan_id"
  end

  create_table "jwt_denylists", force: :cascade do |t|
    t.string "jti", null: false
    t.datetime "exp", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["jti"], name: "index_jwt_denylists_on_jti", unique: true
  end

  create_table "lab_results", force: :cascade do |t|
    t.bigint "scan_id", null: false
    t.string "name"
    t.string "value"
    t.string "unit"
    t.string "status"
    t.string "reference_range"
    t.text "explanation"
    t.integer "sort_order"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["scan_id"], name: "index_lab_results_on_scan_id"
  end

  create_table "prompt_templates", force: :cascade do |t|
    t.string "name", null: false
    t.integer "version", null: false
    t.text "content", null: false
    t.string "ai_model_name", null: false
    t.boolean "active", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_prompt_templates_on_active"
    t.index ["name", "version"], name: "index_prompt_templates_on_name_and_version", unique: true
  end

  create_table "scans", force: :cascade do |t|
    t.bigint "user_id"
    t.string "status"
    t.integer "file_count"
    t.string "urgency"
    t.text "summary"
    t.text "prescription_context"
    t.jsonb "raw_ai_response"
    t.datetime "analyzed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_scans_on_user_id"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "plan"
    t.string "stripe_customer_id"
    t.string "stripe_subscription_id"
    t.string "status"
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_subscriptions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "name"
    t.string "locale", default: "en"
    t.string "plan_type", default: "free"
    t.integer "scans_today", default: 0
    t.date "scans_reset_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "doctor_questions", "scans"
  add_foreign_key "feedbacks", "lab_results"
  add_foreign_key "feedbacks", "scans"
  add_foreign_key "lab_results", "scans"
  add_foreign_key "scans", "users"
  add_foreign_key "subscriptions", "users"
end
