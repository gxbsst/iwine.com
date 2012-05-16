class WineDetails::PhotosController < ApplicationController
   before_filter :get_photo, :except => [:index]
   before_filter :get_wine_detail
  def index
     @photos = @wine_detail.photos.page params[:page] || 1
  end

  def show
      
  end

  private
  def get_photo
    @photo = Photo.find(params[:id])
  end
  def get_wine_detail
    @wine_detail = Wines::Detail.find(params[:wine_id])
  end
end
