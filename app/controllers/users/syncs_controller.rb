class Users::SyncsController < ApplicationController
  def new
    client = OauthChina::Sina.new
    authorize_url = client.authorize_url
    Rails.cache.write(build_oauth_token_key(client.name, client.oauth_token), client.dump)
    redirect_to authorize_url
  end

  def callback
    client = OauthChina::Sina.load(Rails.cache.read(build_oauth_token_key(params[:type], params[:oauth_token])))
    client.authorize(:oauth_verifier => params[:oauth_verifier])
    results = client.dump

    if results[:access_token] && results[:access_token_secret]
      flash[:notice] = "done"
    else
      flash[:notice] = "fail"
    end

    user_oauth = Users::Oauth.new 
    user_oauth.user_id = current_user.id
    user_oauth.access_token = results[:access_token]
    user_oauth.refresh_token = results[:access_token_secret]
 
    binding.pry

    user_oauth.save
  end

  private

  def build_oauth_token_key(name, oauth_token)
    [name, oauth_token].join("_")
  end
end