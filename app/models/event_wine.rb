class EventWine < ActiveRecord::Base
  belongs_to :event
  belongs_to :wine_detail, :class_name =>  "Wines::Detail"
  # attr_accessible :title, :body
end
