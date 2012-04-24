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

  def create
    @register = Wines::Register.new()
    @register.attributes = params[:wines_register]
    @register.region_tree_id = params[:wines_register][:region].values.pop
    @register.winery_id = 1
    if @register.save
      redirect_to mine_wine_path @register, :notice => "成功上传新酒款！"
    else
      render :action => "new"
    end
  end
end
