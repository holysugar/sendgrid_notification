# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_11_25_125857) do

  create_table "mail_histories", force: :cascade do |t|
    t.string "key", null: false
    t.string "to", null: false
    t.datetime "sent_at", null: false
    t.string "error_type"
    t.text "error_reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "attachment_summary"
    t.index ["to"], name: "index_mail_histories_on_to"
  end

  create_table "notification_mails", force: :cascade do |t|
    t.string "key", null: false
    t.string "subject", null: false
    t.text "content", limit: 16777215, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_notification_mails_on_key", unique: true
  end

  create_table "sendgrid_status_update_histories", force: :cascade do |t|
    t.integer "start_time", null: false
    t.integer "end_time", null: false
    t.integer "count"
    t.text "body", limit: 4294967295
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
