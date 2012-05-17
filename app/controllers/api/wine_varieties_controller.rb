class Api::WineVarietiesController < ApplicationController
 def index
   @varieties = Wines::Variety.order(:name_en).where("name_en like ?", "%#{params[:term]}%").limit(15)
   render json: @varieties.map(&:name_en)
 end
end
