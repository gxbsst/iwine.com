class UsersController < ApplicationController
  #before_filter :authenticate_user!, :except => [:index, :show]

  def show
    @user = User.find params[:id]
  end

  def profile
    #@profile = current_user.user_profile || current_user.build_user_profile
    # if @profile == nil
    #   @profile = current_user.build_user_profile
    # endp
    @photo = Photo.new

    if request.post?
      @photo.attributes = params[:photo]
      @photo.owner_type = OWNER_TYPE_WINE
      @photo.business_id = 100
      @photo.user_id = 1

      if @photo.save
        #redirect_to '/users/profile'
      end
    end
  end
end