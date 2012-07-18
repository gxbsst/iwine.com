class Users::Oauth < ActiveRecord::Base
  set_table_name "user_oauths"
  attr_accessor :sns_info
  belongs_to :user
  scope :oauth_record, ->(sns_name){ where(["sns_name = ?", sns_name])}
  
  def tokens
    { :access_token => access_token, :access_token_secret => refresh_token }
  end

end
