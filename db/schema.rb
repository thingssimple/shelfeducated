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

ActiveRecord::Schema.define(version: 20140323084036) do

  create_table "books", force: true do |t|
    t.string "name"
    t.string "slug"
  end

  create_table "chapters", force: true do |t|
    t.integer "book_id"
    t.string  "name"
    t.string  "slug"
    t.string  "question1"
    t.string  "question2"
    t.string  "question3"
    t.string  "question4"
  end

  create_table "conclusions", force: true do |t|
    t.integer "book_id"
    t.string  "question1"
    t.string  "question2"
    t.string  "question3"
    t.string  "question4"
  end

  create_table "users", force: true do |t|
    t.string "email"
    t.string "password"
    t.string "password_salt"
  end

end
