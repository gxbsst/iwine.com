class Api::WineVarietiesController < ApplicationController
 def index
   @varieties = Wines::Variety.order(:name).where("name like ?", "%#{params[:term]}%")
   render json: @varieties.map(&:name)
 end
end
