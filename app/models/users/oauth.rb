class Users::Oauth < ActiveRecord::Base
  include Users::UserSupport
  scope :oauth_record, ->(sns_name){ where(["sns_name = ?", sns_name])}
  
  def tokens
    { :access_token => access_token, :access_token_secret => refresh_token }
  end

end