class WineComment < ::Comment
  fires :new_comment, :on                 => :create,
                      :actor              => :user,
                      :secondary_actor => :commentable
end
