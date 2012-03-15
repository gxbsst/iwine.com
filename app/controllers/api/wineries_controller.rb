class Api::WineriesController < ApplicationController
 def names
   @wineries = Winery.order(:name_en).where("name_en like ?", "%#{params[:term]}%")
   render json: @wineries.map(&:name)
 end
end
