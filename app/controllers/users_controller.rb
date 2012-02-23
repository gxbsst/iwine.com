class UsersController < ApplicationController
  before_filter :authenticate_user!, :except => [:index, :show]

  def show
    @user = User.find params[:id]
  end

  def profile
    @profile = current_user.user_profile || current_user.build_user_profile
  end

  def avatar
    @photos = current_user.photos
    @photo = current_user.avatar || Photo.new
    if request.post?
      @photo.attributes = params[:photo]
      @photo.owner_type = OWNER_TYPE_USER
      @photo.business_id = current_user.id
      @photo.save
      redirect_to '/users/avatar'
    end
  end

  def editAvatar
    @photo = Photo.find params[:id]
  end
end