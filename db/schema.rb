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

ActiveRecord::Schema.define(version: 20160511182348) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "attachments", force: :cascade do |t|
    t.string   "url",        null: false
    t.integer  "message_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "name"
  end

  create_table "bans", force: :cascade do |t|
    t.integer  "user_id",                                                null: false
    t.date     "expiration",                                             null: false
    t.boolean  "active",     default: true,                              null: false
    t.string   "message",    default: "Your account has been suspended", null: false
    t.datetime "created_at",                                             null: false
    t.datetime "updated_at",                                             null: false
  end

  create_table "claims", force: :cascade do |t|
    t.integer  "user_id",    null: false
    t.integer  "task_id",    null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "conversations", force: :cascade do |t|
    t.integer  "project_id", null: false
    t.string   "token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "conversers", force: :cascade do |t|
    t.integer  "conversation_id", null: false
    t.integer  "user_id",         null: false
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "images", force: :cascade do |t|
    t.string   "url",            null: false
    t.integer  "imageable_id",   null: false
    t.string   "imageable_type", null: false
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "invites", force: :cascade do |t|
    t.integer  "user_id",    null: false
    t.string   "email",      null: false
    t.integer  "project_id", null: false
    t.string   "token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "message_users", force: :cascade do |t|
    t.integer  "user_id",                    null: false
    t.integer  "message_id",                 null: false
    t.boolean  "read",       default: false, null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "messages", force: :cascade do |t|
    t.integer  "user_id",                                  null: false
    t.text     "content",         default: "(No Content)", null: false
    t.integer  "conversation_id",                          null: false
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
  end

  create_table "notifications", force: :cascade do |t|
    t.integer  "user_id",                    null: false
    t.text     "content",                    null: false
    t.boolean  "read",       default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "password_recoveries", force: :cascade do |t|
    t.integer  "user_id",                   null: false
    t.string   "token"
    t.boolean  "active",     default: true, null: false
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "projects", force: :cascade do |t|
    t.string   "name",                      null: false
    t.string   "token"
    t.boolean  "active",     default: true, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "requests", force: :cascade do |t|
    t.integer  "user_id",                   null: false
    t.integer  "project_id",                null: false
    t.boolean  "active",     default: true, null: false
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "settings", force: :cascade do |t|
    t.integer  "user_id",                            null: false
    t.integer  "inactive_time",       default: 10,   null: false
    t.boolean  "email_notifications", default: true, null: false
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  create_table "subscriptions", force: :cascade do |t|
    t.integer  "user_id",                   null: false
    t.string   "stripe_customer_token"
    t.string   "stripe_subscription_token"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "tasks", force: :cascade do |t|
    t.integer  "message_id",                   null: false
    t.boolean  "completed",    default: false, null: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.integer  "completer_id"
  end

  create_table "tiers", force: :cascade do |t|
    t.string   "name",                             null: false
    t.integer  "admin_projects",                   null: false
    t.integer  "users_per_project",                null: false
    t.boolean  "published",         default: true, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "monthly_id"
    t.integer  "yearly_id"
    t.boolean  "business"
  end

  create_table "user_projects", force: :cascade do |t|
    t.integer  "project_id",                 null: false
    t.integer  "user_id",                    null: false
    t.boolean  "admin",      default: false, null: false
    t.boolean  "approved",   default: false, null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "username",                        null: false
    t.string   "first_name",                      null: false
    t.string   "last_name",                       null: false
    t.string   "email",                           null: false
    t.string   "password_digest",                 null: false
    t.integer  "tier_id",         default: 1,     null: false
    t.integer  "visits",          default: 0,     null: false
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.boolean  "owner",           default: false
    t.datetime "last_online"
  end

end
