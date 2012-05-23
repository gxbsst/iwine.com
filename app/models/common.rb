module Common
  # instance methods

  def is_followed? user
    return comments.where("user_id = ? and do = ? and deleted_at is null", user.id, 'follow').first ? true : false
  end

  def find_follow user
    comments.where("user_id = ? and do = ? and deleted_at is null", user.id, 'follow').first
  end
end