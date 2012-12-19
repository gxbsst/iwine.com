class NoteComment < ::Comment
  # fires :new_comment, :on                 => :create,
  #                     :actor              => :user,
  #                     :secondary_actor => :commentable,
  #                     :if => lambda {|wine_comment| wine_comment.is_share}

  after_save :flush_counter_cache  # delete Cache

  def flush_counter_cache
    #Rails.cache.delete([commentable, :comments_counter])
  end

end
