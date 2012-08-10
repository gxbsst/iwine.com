class OauthComment < ActiveRecord::Base
  attr_accessible :comment_id, :sns_id, :sns_type
  belongs_to :comment

  def sns_comments
  	comment.get_sns_comments(self)
  end
end
