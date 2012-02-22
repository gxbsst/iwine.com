class UsersController < ApplicationController
  before_filter :authenticate_user!, :except => [:index, :show]

  def show
    @user = User.find params[:id]
  end

  def profile
    @profile = current_user.user_profile
    if @profile == nil
      @profile = current_user.build_user_profile
    end

    if request.post?
      @profile.attributes = params[:profile]
      if @profile.save
        redirect_to '/users/profile'
      end
    end
  end

end
