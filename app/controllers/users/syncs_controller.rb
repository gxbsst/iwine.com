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
<<<<<<< HEAD
=======
    binding.pry
>>>>>>> b4fa0bab478f615081a130699bac5c57e3d5bcad
    results = client.dump

    if results[:access_token] && results[:access_token_secret]
      flash[:notice] = "done"
    else
      flash[:notice] = "fail"
    end

    user_oauth = Users::Oauth.new 
    user_oauth.user_id = current_user.id
    user_oauth.access_token = results[:access_token]
<<<<<<< HEAD
    user_oauth.sns_name = "sina"
    user_oauth.refresh_token = results[:access_token_secret]
    user_oauth.save
  end
  
  # 获取好友
  # def friends
  #    tokens = current_user.oauths.oauth_record('sina').first.tokens
  #    client = OauthChina::Sina.load(tokens)
  #    client.friends
  # end

=======
    user_oauth.sns_name = client.name.to_s
    user_oauth.sns_user_id = client.me["id"]
    user_oauth.refresh_token = results[:access_token_secret]
    user_oauth.save

  end

  def show

  end
  
>>>>>>> b4fa0bab478f615081a130699bac5c57e3d5bcad
  private

  def build_oauth_token_key(name, oauth_token)
    [name, oauth_token].join("_")
  end
<<<<<<< HEAD
=======

  def client
    tokens = current_user.oauths.oauth_record('sina').first.tokens
    @client ||= OauthChina::Sina.load(tokens)
  end

>>>>>>> b4fa0bab478f615081a130699bac5c57e3d5bcad
end