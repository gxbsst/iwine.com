class PhotoComment < ActiveRecord::Base

  belongs_to :reply_to, :class_name => 'PhotoComment', :foreign_key => 'reply_id'


  belongs_to :user
  
end