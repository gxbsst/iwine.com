class UsersController < ApplicationController
  def profile
    @photo = Photo.new
    if request.post?
      @photo.attributes = params[:photo]
      @photo.owner_type = OWNER_TYPE_WINE
      @photo.business_id= 1010
      if @photo.save
        flash[:success] = 'Save Success'
      end
    end
  end
end
