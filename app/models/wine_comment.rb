class WineComment < ::Comment
  fires :new_comment, :on                 => :create,
                      :actor              => :user,
                      :secondary_actor => :commentable,
                      :if => lambda { |comment| comment.commentable_type == "Wines::Detail" }
end
