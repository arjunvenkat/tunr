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

ActiveRecord::Schema.define(version: 20150302195158) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "episodes", force: :cascade do |t|
    t.integer  "podcast_id"
    t.string   "season"
    t.integer  "episode_num"
    t.string   "title"
    t.text     "desc"
    t.integer  "duration"
    t.date     "published_date"
    t.string   "url"
    t.boolean  "explicit"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.float    "rating",         default: 0.0
  end

  create_table "followings", force: :cascade do |t|
    t.integer  "follower_id"
    t.integer  "followed_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "podcasts", force: :cascade do |t|
    t.string   "name"
    t.string   "published_by"
    t.text     "desc"
    t.string   "update_freq"
    t.string   "update_day"
    t.string   "image_url"
    t.string   "host"
    t.string   "created_by"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "reviews", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "episode_id"
    t.integer  "rating"
    t.text     "contents"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "upvoted_count", default: 0
  end

  create_table "upvotes", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "review_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "username"
    t.string   "email"
    t.string   "fname"
    t.string   "lname"
    t.string   "sex"
    t.text     "desc"
    t.string   "image_url"
    t.string   "age_range"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.integer  "upvoted_count",          default: 0
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
