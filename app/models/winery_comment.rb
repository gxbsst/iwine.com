class WineryComment < Comment
  fires :new_comment,
        :on              => :create,
        :actor           => :user,
        :secondary_actor => :commentable,
        :if => lambda {|winery_comment| winery_comment.is_share}
end