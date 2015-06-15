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

ActiveRecord::Schema.define(version: 20150608210455) do

  create_table "fields", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "location"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "fields", ["user_id"], name: "index_fields_on_user_id"

  create_table "games", force: :cascade do |t|
    t.integer  "team_one"
    t.integer  "team_two"
    t.datetime "date_time"
    t.integer  "team_one_score", default: 0
    t.integer  "team_two_score", default: 0
    t.integer  "user_id"
    t.integer  "tournament_id"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "field_id"
  end

  add_index "games", ["user_id"], name: "index_games_on_user_id"

  create_table "players", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.integer  "team_id"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "teams", force: :cascade do |t|
    t.string   "name"
    t.integer  "user_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "won"
    t.integer  "lost"
    t.integer  "draw"
    t.integer  "goalsfor"
    t.integer  "goalsagainst"
  end

  add_index "teams", ["user_id"], name: "index_teams_on_user_id"

  create_table "timeslots", force: :cascade do |t|
    t.datetime "start"
    t.datetime "end"
    t.integer  "field"
    t.integer  "user_id"
    t.integer  "field_id"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.boolean  "available",  default: true
  end

  create_table "tournaments", force: :cascade do |t|
    t.string   "name"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "tournaments", ["user_id"], name: "index_tournaments_on_user_id"

  create_table "users", force: :cascade do |t|
    t.string   "firstname",              default: ""
    t.string   "lastname",               default: ""
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

end
