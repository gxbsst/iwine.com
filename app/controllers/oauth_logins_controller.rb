
class OauthLoginsController < ApplicationController
  def sns_login
  	sns_class_name = params[:sns_name].capitalize
    oauth_module = eval( "OauthChina::#{sns_class_name}" )
    client = oauth_module.new
    #替换掉oauth_china 默认的callback
    authorize_url = client.authorize_url
    Rails.cache.write(build_oauth_token_key(client.name, client.oauth_token), client.dump)
    redirect_to authorize_url.gsub(/oauth_callback.*?&/, "oauth_callback=" + OAUTH_DATA["#{params[:sns_name]}"]["callback"] + "&")
  end

  def update_info

  end

  private

  def build_oauth_token_key(name, oauth_token)
    [name, oauth_token].join("_")
  end
end
