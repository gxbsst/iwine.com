class NoteComment < ::Comment
  # fires :new_comment, :on                 => :create,
  #                     :actor              => :user,
  #                     :secondary_actor => :commentable,
  #                     :if => lambda {|wine_comment| wine_comment.is_share}

end
