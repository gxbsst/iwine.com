class Users::AlbumsController < ApplicationController

  def show

  end

  def upload 
    @albums = current_user.albums

    if @albums.blank?
      avatar_album = Album.create :created_by => params[:user_id] , :name => 'avatar', :owner_type => OWNER_TYPE_USER 
      default_album = Album.create :created_by => params[:user_id] , :name => 'other', :owner_type => OWNER_TYPE_USER

      @albums = [avatar_album, default_album]
    end
  end

  def new
    if request.post?
      @album = Album.create :created_by => current_user.id, :name => params[:name], :owner_type => OWNER_TYPE_USER
      redirect_to request.referer
      return
    end

    render :layout => false
  end
end