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

ActiveRecord::Schema.define(version: 2021_07_28_102654) do

  create_table "duplicate_temps", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.text "url"
    t.date "date_created"
    t.text "license_group"
    t.text "license_number"
    t.text "price"
    t.text "location"
    t.text "license_status"
    t.text "color"
    t.text "processing_status"
    t.text "is_duplicate"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "kaitabien_details", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.text "url"
    t.date "date_created"
    t.text "license_group"
    t.text "license_number"
    t.text "price"
    t.text "location"
    t.text "license_status"
    t.text "color"
    t.text "processing_status"
    t.text "is_duplicate"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "lekpramool_details", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.text "url"
    t.date "date_created"
    t.text "license_group"
    t.text "license_number"
    t.text "price"
    t.text "location"
    t.text "license_status"
    t.text "color"
    t.text "processing_status"
    t.text "is_duplicate"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "licence_details", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.date "date_created"
    t.text "url"
    t.text "license_group"
    t.text "license_number"
    t.text "price"
    t.text "location"
    t.text "license_status", null: false
    t.text "color"
    t.text "processing_status"
    t.text "is_duplicate"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tabien999_details", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.text "url"
    t.date "date_created"
    t.text "license_group"
    t.text "license_number"
    t.text "price"
    t.text "location"
    t.text "license_status"
    t.text "color"
    t.text "processing_status"
    t.text "is_duplicate"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tabien9_details", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.text "url"
    t.date "date_created"
    t.text "license_group"
    t.text "license_number"
    t.text "price"
    t.text "location"
    t.text "license_status"
    t.text "color"
    t.text "processing_status"
    t.text "is_duplicate"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tabiend789_details", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.text "url"
    t.date "date_created"
    t.text "license_group"
    t.text "license_number"
    t.text "price"
    t.text "location"
    t.text "license_status"
    t.text "color"
    t.text "processing_status"
    t.text "is_duplicate"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tabieninfinity_details", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.text "url"
    t.date "date_created"
    t.text "license_group"
    t.text "license_number"
    t.text "price"
    t.text "location"
    t.text "license_status"
    t.text "color"
    t.text "processing_status"
    t.text "is_duplicate"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tabienrodnamchock_details", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.text "url"
    t.date "date_created"
    t.text "license_group"
    t.text "license_number"
    t.text "price"
    t.text "location"
    t.text "license_status"
    t.text "color"
    t.text "processing_status"
    t.text "is_duplicate"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "teeneetabien_details", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.text "url"
    t.date "date_created"
    t.text "license_group"
    t.text "license_number"
    t.text "price"
    t.text "location"
    t.text "license_status"
    t.text "color"
    t.text "processing_status"
    t.text "is_duplicate"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
