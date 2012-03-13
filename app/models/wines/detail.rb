class Wines::Detail < ActiveRecord::Base
  include Wines::WineSupport
  
  belongs_to :wine

  has_many :comments, :foreign_key => 'wine_detail_id'

#  has_many :good_comments, :foreign_key => 'wine_detail_id', :class_name => 'Wines::Comment', :order => 'good_hit DESC, id DESC', :limit => 5, :include => [:user_good_hit] 

  has_one :statistic, :foreign_key => 'wine_detail_id'

  def comment( user_id )
    Wines::Comment.find_by_user_id user_id
  end

  def best_comments
    Wines::Comment.find(:all, :include => [:user, :avatar, :user_good_hit], :limit => 5, :conditions => ["wine_detail_id = ?", id])
  end
end
