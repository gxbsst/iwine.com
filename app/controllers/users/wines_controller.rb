# encoding: UTF-8
class Users::WinesController < ApplicationController
  before_filter :require_user
  before_filter :find_register, :only => [:show, :edit, :update]
  before_filter :check_region_tree, :only => :create
  before_filter :check_edit_register, :only => [:edit, :update]
  def add
    if params[:step].to_i == 1
      @search = ::Search.new
      render :template => "mine/wines/add_step_one"
    elsif params[:step].to_i == 2
      @search = Search.find(params[:id])
      render :template => "mine/wines/add_step_two"
    end
  end

  def show
  end

  def edit
  end

  def update
    params[:wines_register].delete('special_comments')
    Wines::SpecialComment.build_special_comment(@register, params[:special_comment])
    @register.result = 1 #设置为一，用户无法再编辑
    if @register.update_attributes(params[:wines_register])
      redirect_to mine_wine_path(@register)
    else
      render :action => :edit
    end

  end

  def new
    if params[:wine_detail_id]
      @read_only = true
      @wine_detail = Wines::Detail.find(params[:wine_detail_id].to_i)
      @wine = @wine_detail.wine
      @register = Wines::Register.create(
        :name_en => @wine.name_en,
        :vintage => @wine_detail.year,
        :official_site => @wine.official_site,
        :wine_style_id => @wine.wine_style_id,
        :region_tree_id => @wine.region_tree_id,
        :user_id => current_user.id,
        :winery_id => 1
      )
    else
      @register = current_user.registers.new()
    end
    if request.post?
      @register.attributes = params[:wines_register]
      @register.owner_type = OWNER_TYPE_WINE_REGISTER
      if @register.save
        flash[:notice] =  :save_success
      end
    end
  end

  def create
    @register = params[:register_id] ? Wines::Register.find_by_id(params[:register_id]) : current_user.registers.new(params[:wines_register])
    @register.attributes = params[:wines_register]
    @register.region_tree_id ||= @region_tree_id
    @register.variety_name = @register.variety_name_value
    @register.variety_percentage = @register.variety_percentage_value
    if @register.save
      flash[:notice] = "成功上传新酒款！"
      redirect_to edit_mine_wine_path @register
    else
      render :action => "new"
    end
  end


  private

  def check_edit_register
    if @register.result.to_i == 1

      #flash[:notice] = "已经成功上传，不能再次修改！"
      notice_stickie("已经成功上传，不能再次修改")
      redirect_to mine_wine_path(@register)
    end
  end

  def check_region_tree
    if params[:region]
      @region_tree_id = params[:region].values.delete_if{|a| a == ""}.pop
    end
  end

  def find_register
    @register = Wines::Register.find(params[:id])
  end
end
