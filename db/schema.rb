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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120320065718) do

  create_table "active_admin_comments", :force => true do |t|
    t.string   "resource_id",   :null => false
    t.string   "resource_type", :null => false
    t.integer  "author_id"
    t.string   "author_type"
    t.text     "body"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "namespace"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], :name => "index_active_admin_comments_on_author_type_and_author_id"
  add_index "active_admin_comments", ["namespace"], :name => "index_active_admin_comments_on_namespace"
  add_index "active_admin_comments", ["resource_type", "resource_id"], :name => "index_admin_notes_on_resource_type_and_resource_id"

  create_table "admin_users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "admin_users", ["email"], :name => "index_admin_users_on_email", :unique => true
  add_index "admin_users", ["reset_password_token"], :name => "index_admin_users_on_reset_password_token", :unique => true

  create_table "albums", :force => true do |t|
    t.string   "name",          :limit => 45,                    :null => false
    t.integer  "user_id"
    t.text     "intro"
    t.boolean  "is_order_asc",                :default => false, :null => false
    t.integer  "cover_id",                    :default => 0
    t.integer  "photos_num",                  :default => 0
    t.integer  "viewed_num",                  :default => 0
    t.integer  "commented_num",               :default => 0
    t.integer  "liked_num",                   :default => 0
    t.datetime "deleted_at"
    t.integer  "created_by",                                     :null => false
    t.datetime "created_at",                                     :null => false
    t.datetime "updated_at",                                     :null => false
  end

  create_table "audit_logs", :force => true do |t|
    t.integer  "result",      :limit => 1
    t.string   "type",        :limit => 48, :null => false
    t.integer  "business_id",               :null => false
    t.integer  "created_by"
    t.text     "comment"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  create_table "friendships", :force => true do |t|
    t.integer  "following"
    t.integer  "follower"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "photo_comments", :force => true do |t|
    t.integer  "user_id",                            :null => false
    t.integer  "reply_user_id",   :default => 0,     :null => false
    t.integer  "photo_id",                           :null => false
    t.text     "comment",                            :null => false
    t.boolean  "deleted_statues", :default => false, :null => false
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
  end

  add_index "photo_comments", ["photo_id", "created_at", "deleted_statues"], :name => "photo_id"

  create_table "photos", :force => true do |t|
    t.string   "image"
    t.integer  "owner_type"
    t.integer  "business_id"
    t.text     "intro"
    t.string   "category",      :limit => 0, :default => ""
    t.integer  "size"
    t.integer  "album_id"
    t.integer  "width",                      :default => 0
    t.integer  "height",                     :default => 0
    t.integer  "viewed_num",                 :default => 0
    t.integer  "commented_num",              :default => 0
    t.integer  "liked_num",                  :default => 0
    t.datetime "deleted_at"
    t.boolean  "is_cover",                   :default => false
    t.integer  "audit_id"
    t.integer  "audit_status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "regions", :force => true do |t|
    t.integer  "parent_id",   :limit => 2,   :default => 0,     :null => false
    t.string   "region_name", :limit => 120, :default => "",    :null => false
    t.boolean  "region_type",                :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "regions", ["parent_id"], :name => "parent_id"
  add_index "regions", ["region_type"], :name => "region_type"

  create_table "searches", :force => true do |t|
    t.string   "keywords"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "settings", :force => true do |t|
    t.string   "name"
    t.string   "value"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "social_message_posts", :force => true do |t|
    t.integer  "message_id", :limit => 8, :default => 0, :null => false
    t.text     "message",                                :null => false
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "social_message_posts", ["message_id"], :name => "message_id"

  create_table "social_messages", :force => true do |t|
    t.integer  "sender_id",                         :default => 0,     :null => false
    t.string   "sender",              :limit => 25, :default => "",    :null => false
    t.integer  "recipient_id",                      :default => 0,     :null => false
    t.string   "recipient",           :limit => 25, :default => "",    :null => false
    t.string   "subject",                           :default => "",    :null => false
    t.boolean  "read",                              :default => false, :null => false
    t.boolean  "no_reply",                                             :null => false
    t.integer  "send_time",                         :default => 0,     :null => false
    t.integer  "read_time",                         :default => 0,     :null => false
    t.boolean  "delete_by_sender",                  :default => false, :null => false
    t.boolean  "delete_by_recipient",               :default => false, :null => false
    t.datetime "created_at",                                           :null => false
    t.datetime "updated_at",                                           :null => false
  end

  add_index "social_messages", ["recipient_id", "send_time", "delete_by_recipient"], :name => "recipient_id"
  add_index "social_messages", ["sender_id", "send_time", "delete_by_sender"], :name => "sender_id"

  create_table "user_good_hit_comments", :force => true do |t|
    t.integer  "user_id",    :null => false
    t.integer  "comment_id", :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "user_interests", :primary_key => "user_id", :force => true do |t|
    t.text     "types"
    t.text     "areas"
    t.text     "wineries"
    t.text     "wines"
    t.text     "makers"
    t.text     "critics"
    t.text     "been_to_wineries_and_areas"
    t.text     "events"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  create_table "user_invite_logs", :force => true do |t|
    t.integer  "user_id",    :null => false
    t.integer  "invitor_id", :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "user_oauths", :force => true do |t|
    t.integer  "user_id",                                      :null => false
    t.string   "sns_name",      :limit => 30,  :default => "", :null => false
    t.string   "sns_user_id",   :limit => 128
    t.string   "access_token",  :limit => 128
    t.string   "refresh_token", :limit => 128
    t.string   "session_key",   :limit => 128
    t.integer  "activation",    :limit => 1,   :default => 0,  :null => false
    t.datetime "created_at",                                   :null => false
    t.datetime "updated_at",                                   :null => false
  end

  create_table "user_profiles", :force => true do |t|
    t.integer  "user_id",                                           :null => false
    t.string   "nickname",            :limit => 128
    t.text     "bio"
    t.integer  "living_city"
    t.integer  "hometown"
    t.string   "gender",              :limit => 0
    t.date     "birthday"
    t.integer  "vocation"
    t.string   "company",             :limit => 100
    t.string   "real_name",           :limit => 100
    t.string   "school",              :limit => 100
    t.string   "phone_number",        :limit => 100
    t.string   "qq",                  :limit => 10
    t.string   "msn",                 :limit => 100
    t.integer  "relationship"
    t.string   "website"
    t.integer  "notify_status"
    t.integer  "nickname_updated_at",                :default => 0, :null => false
    t.datetime "created_at",                                        :null => false
    t.datetime "updated_at",                                        :null => false
    t.text     "_config"
    t.string   "contact_email"
  end

  add_index "user_profiles", ["user_id"], :name => "user_profile_FI_1"

  create_table "user_wine_cellar_items", :force => true do |t|
    t.integer  "user_wine_cellar_id"
    t.integer  "wine_detail_id"
    t.integer  "user_id"
    t.float    "price"
    t.integer  "inventory"
    t.datetime "drinkable_begin"
    t.datetime "drinkable_end"
    t.string   "buy_from",            :limit => 64
    t.datetime "buy_date"
    t.string   "location",            :limit => 64
    t.datetime "deleted_at"
    t.integer  "private_type",                      :default => 4
    t.float    "value"
    t.datetime "created_at",                                       :null => false
    t.datetime "updated_at",                                       :null => false
    t.integer  "number",                            :default => 0
  end

  create_table "user_wine_cellars", :force => true do |t|
    t.integer  "user_id"
    t.string   "title",            :limit => 128
    t.text     "description"
    t.string   "file_name",        :limit => 128
    t.string   "file_origin_name", :limit => 128
    t.integer  "private_type",                    :default => 4
    t.boolean  "tradable",                        :default => true
    t.boolean  "notifiable",                      :default => true
    t.datetime "deleted_at"
    t.datetime "created_at",                                        :null => false
    t.datetime "updated_at",                                        :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "",   :null => false
    t.string   "username",               :default => "",   :null => false
    t.string   "encrypted_password",     :default => "",   :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",        :default => 0
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.string   "authentication_token"
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
    t.string   "role"
    t.boolean  "agree_term",             :default => true
  end

  add_index "users", ["authentication_token"], :name => "index_users_on_authentication_token", :unique => true
  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["unlock_token"], :name => "index_users_on_unlock_token", :unique => true

  create_table "wine_comments", :force => true do |t|
    t.integer  "wine_detail_id",                              :null => false
    t.integer  "user_id",                                     :null => false
    t.text     "content"
    t.integer  "good_hit",                     :default => 0
    t.integer  "point",          :limit => 1,  :default => 0
    t.string   "drink_status",   :limit => 40
    t.integer  "flag",           :limit => 1,  :default => 0
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
  end

  create_table "wine_details", :force => true do |t|
    t.integer  "drinkable_begin"
    t.integer  "drinkable_end"
    t.integer  "price"
    t.string   "alcoholicity",    :limit => 45
    t.string   "capacity",        :limit => 45
    t.integer  "wine_style_id"
    t.integer  "wine_id"
    t.integer  "year"
    t.string   "unique_url",      :limit => 128
    t.integer  "audit_id"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  add_index "wine_details", ["wine_id"], :name => "wine_id"

  create_table "wine_drinkers", :force => true do |t|
    t.integer  "user_id"
    t.integer  "status"
    t.integer  "wine_detail_id", :null => false
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "wine_drinkers", ["wine_detail_id"], :name => "fk_wine_detail1"

  create_table "wine_labels", :force => true do |t|
    t.string   "filename",      :limit => 128, :null => false
    t.string   "md5_signature", :limit => 128, :null => false
    t.string   "origin_name",   :limit => 128
    t.integer  "size"
    t.integer  "width"
    t.integer  "height"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
  end

  add_index "wine_labels", ["filename"], :name => "wine_label_U_1", :unique => true

  create_table "wine_prices", :force => true do |t|
    t.integer  "wine_detail_id"
    t.integer  "user_id"
    t.float    "price"
    t.string   "from",           :limit => 128
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  create_table "wine_region_trees", :force => true do |t|
    t.integer  "parent_id"
    t.string   "name_en",    :limit => 45
    t.string   "name_zh",    :limit => 45
    t.integer  "tree_right",               :null => false
    t.integer  "tree_left",                :null => false
    t.integer  "scope",                    :null => false
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  create_table "wine_registers", :force => true do |t|
    t.string   "name_zh",            :limit => 128
    t.string   "name_en",            :limit => 128
    t.string   "official_site",      :limit => 100
    t.integer  "wine_style_id"
    t.integer  "region_tree_id"
    t.integer  "winery_id"
    t.string   "photo_name",         :limit => 100
    t.string   "photo_origin_name"
    t.integer  "vintage"
    t.integer  "drinkable_begin",    :limit => 1
    t.integer  "drinkable_end",      :limit => 1
    t.string   "alcoholicity",       :limit => 45
    t.string   "variety_percentage", :limit => 128
    t.string   "variety_name"
    t.string   "capacity",           :limit => 45
    t.integer  "status",             :limit => 1,   :default => 0
    t.integer  "audit_log_id"
    t.integer  "user_id"
    t.integer  "result"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "other_cn_name"
  end

  create_table "wine_statistics", :force => true do |t|
    t.integer  "wine_detail_id",                     :null => false
    t.integer  "score_sum",           :default => 0
    t.integer  "score_user_count",    :default => 0
    t.integer  "comment_count",       :default => 0
    t.integer  "comment_user_count",  :default => 0
    t.integer  "to_drink_user_count", :default => 0
    t.integer  "drank_user_count",    :default => 0
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
  end

  create_table "wine_styles", :force => true do |t|
    t.string   "name_en",    :limit => 128, :null => false
    t.string   "name_zh",    :limit => 128
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  create_table "wine_varieties", :force => true do |t|
    t.string   "culture",     :limit => 7, :default => ""
    t.string   "name_zh",                  :default => ""
    t.string   "name_en"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "pinyin"
    t.string   "origin_name"
  end

  add_index "wine_varieties", ["culture"], :name => "culture"

  create_table "wine_variety_percentages", :force => true do |t|
    t.integer  "wine_detail_id",               :null => false
    t.string   "percentage",     :limit => 64
    t.integer  "variety_id",                   :null => false
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
  end

  add_index "wine_variety_percentages", ["wine_detail_id"], :name => "fk_wine_detail"

  create_table "wineries", :force => true do |t|
    t.string   "name_en",        :limit => 45
    t.integer  "region_id",                     :null => false
    t.integer  "region_tree_id",                :null => false
    t.text     "history"
    t.text     "legend"
    t.string   "owner",          :limit => 100
    t.string   "winemaker",      :limit => 100
    t.text     "environment"
    t.text     "multiple"
    t.text     "badge"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.string   "name_zh"
  end

  create_table "wines", :force => true do |t|
    t.string   "name_zh",        :limit => 128
    t.string   "name_en",        :limit => 128
    t.string   "official_site",  :limit => 100
    t.integer  "wine_style_id"
    t.integer  "winery_id",                     :null => false
    t.integer  "region_tree_id",                :null => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.string   "origin_name"
    t.string   "other_cn_name"
  end

  add_index "wines", ["region_tree_id"], :name => "fk_wine_region_tree1"
  add_index "wines", ["winery_id"], :name => "fk_wine_winery1"

end
