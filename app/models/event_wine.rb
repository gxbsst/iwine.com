class EventWine < ActiveRecord::Base
  attr_accessor :wine_detail_ids
  belongs_to :event
  belongs_to :wine_detail, :class_name =>  "Wines::Detail"
  # attr_accessible :title, :body

  class << self
    # 检查某只酒是否已经被添加
    def check_wine_have_been_added?(event_id, wine_detail_id)
      find_by_event_id_and_wine_detail_id(event_id, wine_detail_id).present? 
    end
  end

end
