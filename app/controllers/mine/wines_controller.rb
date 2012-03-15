# encoding: UTF-8
class Mine::WinesController < ApplicationController

  def show

  end

  def new
    @register = Wines::Register.new
    if request.post?
      @register.attributes = params[:wines_register]
      @register.owner_type = OWNER_TYPE_WINE_REGISTER
      if @register.save
        flash[:notice] =  :save_success
      end
    end
  end

end
