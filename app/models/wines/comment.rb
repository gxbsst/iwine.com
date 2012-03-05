
class Wines::Comment < ActiveRecord::Base
  include Wines::WineSupport
  belongs_to :user, :include => [:good_hit_comment]
  has_one :avatar, :class_name => 'Photo', :primary_key => :user_id,  :foreign_key => 'business_id', :conditions => { :is_cover => true }
  has_one :good_hit_comment, :class_name => 'Users::GoodHitComment'
  belongs_to :detail, :class_name => "Wines::Detail", :foreign_key => 'wine_detail_id'
end
