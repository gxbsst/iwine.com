class Users::WineCellar < ActiveRecord::Base

  PRIVATE_TYPE_SECRET = 1
  PRIVATE_TYPE_FRIEND = 2
  PRIVATE_TYPE_USER = 3
  PRIVATE_TYPE_PUBLIC = 4

  include Users::UserSupport

  belongs_to :user
  has_many :items, :class_name => "Users::WineCellarItem", :foreign_key => "user_wine_cellar_id", :include => [:wine_detail]
  #访问他人酒窖
  has_many :user_items, :class_name => "Users::WineCellarItem",
           :foreign_key => "user_wine_cellar_id",
           :include => [:wine_cellar, :wine_detail => [:covers, :wine]],
           :conditions => "private_type = 0"
  #登录时访问自己的酒窖
  has_many :mine_items, :class_name => "Users::WineCellarItem",
           :foreign_key => "user_wine_cellar_id",
           :include => [:wine_cellar, :wine_detail => [:covers, :wine]]
end
