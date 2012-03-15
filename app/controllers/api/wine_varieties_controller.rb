class Api::WineVarietiesController < ApplicationController
 def index
   @varieties = Wines::Variety.order(:name_en).where("name_en like ?", "%#{params[:term]}%")
   render json: @varieties.map(&:name_en)
 end
end
