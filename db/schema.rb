# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100504151338) do

  create_table "admissions", :force => true do |t|
    t.string   "type"
    t.integer  "candidate_id"
    t.string   "candidate_type"
    t.integer  "group_id"
    t.string   "group_type"
    t.integer  "introducer_id"
    t.string   "introducer_type"
    t.string   "email"
    t.integer  "role_id"
    t.text     "comment"
    t.string   "code"
    t.boolean  "accepted"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "processed_at"
  end

  create_table "attachments", :force => true do |t|
    t.string   "type"
    t.integer  "size"
    t.string   "content_type"
    t.string   "filename"
    t.integer  "height"
    t.integer  "width"
    t.integer  "parent_id"
    t.string   "thumbnail"
    t.integer  "db_file_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "db_files", :force => true do |t|
    t.binary "data"
  end

  create_table "feedbacks", :force => true do |t|
    t.string   "email"
    t.string   "subject"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "histories", :force => true do |t|
    t.date     "date"
    t.integer  "uris_count"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "logos", :force => true do |t|
    t.integer  "logoable_id"
    t.string   "logoable_type"
    t.integer  "size"
    t.string   "content_type"
    t.string   "filename"
    t.integer  "height"
    t.integer  "width"
    t.integer  "parent_id"
    t.string   "thumbnail"
    t.integer  "db_file_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "open_id_associations", :force => true do |t|
    t.binary  "server_url"
    t.string  "handle"
    t.binary  "secret"
    t.integer "issued"
    t.integer "lifetime"
    t.string  "assoc_type"
  end

  create_table "open_id_nonces", :force => true do |t|
    t.string  "server_url", :null => false
    t.integer "timestamp",  :null => false
    t.string  "salt",       :null => false
  end

  create_table "open_id_ownings", :force => true do |t|
    t.integer "agent_id"
    t.string  "agent_type"
    t.integer "uri_id"
    t.boolean "local",      :default => false
  end

  create_table "open_id_trusts", :force => true do |t|
    t.integer "agent_id"
    t.string  "agent_type"
    t.integer "uri_id"
  end

  create_table "performances", :force => true do |t|
    t.integer "agent_id"
    t.string  "agent_type"
    t.integer "stage_id"
    t.string  "stage_type"
    t.integer "role_id"
  end

  create_table "permissions", :force => true do |t|
    t.string "action"
    t.string "objective"
  end

  create_table "permissions_roles", :id => false, :force => true do |t|
    t.integer "permission_id"
    t.integer "role_id"
  end

  create_table "posts", :force => true do |t|
    t.text     "content"
    t.integer  "parent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", :force => true do |t|
    t.string "name"
    t.string "stage_type"
  end

  create_table "singular_agents", :force => true do |t|
    t.string "type"
  end

  create_table "sites", :force => true do |t|
    t.string   "name",                          :default => "Station powered Rails site"
    t.text     "description"
    t.string   "domain",                        :default => "station.example.org"
    t.string   "email",                         :default => "admin@example.org"
    t.boolean  "ssl",                           :default => false
    t.boolean  "exception_notifications",       :default => false
    t.string   "exception_notifications_email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "source_importations", :force => true do |t|
    t.integer  "source_id"
    t.integer  "importation_id"
    t.string   "importation_type"
    t.integer  "uri_id"
    t.string   "guid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sources", :force => true do |t|
    t.integer  "uri_id"
    t.string   "content_type"
    t.string   "target"
    t.integer  "container_id"
    t.string   "container_type"
    t.datetime "imported_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "taggings", :force => true do |t|
    t.integer "tag_id"
    t.integer "taggable_id"
    t.string  "taggable_type"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type"], :name => "index_taggings_on_tag_id_and_taggable_id_and_taggable_type"

  create_table "tags", :force => true do |t|
    t.string  "name"
    t.integer "container_id"
    t.string  "container_type"
    t.integer "taggings_count", :default => 0
  end

  add_index "tags", ["name", "container_id", "container_type"], :name => "index_tags_on_name_and_container_id_and_container_type"

  create_table "uri_properties", :force => true do |t|
    t.integer "uri_id"
    t.boolean "foaf"
    t.boolean "atompub"
    t.boolean "rsd"
    t.text    "microformats"
    t.text    "xrds_service_types"
    t.boolean "atom"
    t.boolean "rss"
    t.boolean "link_openid_server"
    t.boolean "link_openid2_provider"
    t.text    "openid_providers"
  end

  create_table "uris", :force => true do |t|
    t.string "uri"
  end

  add_index "uris", ["uri"], :name => "index_uris_on_uri"

end
