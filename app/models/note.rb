class Note < ActiveRecord::Base
  attr_accessible :name, :orther_name
  belongs_to :user
end