
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
  	#向第三方请求用户信息
  	sns_class_name = params[:type].capitalize
    oauth_module = eval( "OauthChina::#{sns_class_name}" )
    client = oauth_module.load(Rails.cache.read(build_oauth_token_key(params[:type], params[:oauth_token])))
    client.authorize(:oauth_verifier => params[:oauth_verifier])
    results = client.dump

    if results[:access_token] && results[:access_token_secret]
      flash[:notice] = "done"
    else
      flash[:notice] = "fail"
    end
    # 创建UserOauth记录
    user_oauth = Users::Oauth.login_oauth.where("sns_name = ? and sns_user_id = ?", client.name.to_s, client.user_id)
    if user_oauth.present?
      
    else

    end
    user_oauth = current_user.oauth_token client.name.to_s
    user_oauth.access_token = results[:access_token]
    user_oauth.sns_user_id = client.user_id # sns.rb Sina#user_id
    user_oauth.refresh_token = results[:access_token_secret]
    user_oauth.save

  end

  def sns_first_login

  end

  private

  def build_oauth_token_key(name, oauth_token)
    [name, oauth_token].join("_")
  end
end
