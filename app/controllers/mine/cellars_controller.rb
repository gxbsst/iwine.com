# encoding: UTF-8
class Mine::CellarsController < ApplicationController



  def index
    @cellar_items = Users::WineCellarItem.includes(:wine_cellar, {:wine_detail => [:covers, :wine]}).page params[:page] || 1
  end

  def edit
    @cellar_item = Users::WineCellarItem.where(["id = ? AND user_id = ? ", params[:id], current_user.id ]).first
    @wine_detail = Wines::Detail.includes( :cover, :photos, :statistic,  { :wine => [:style, :winery]} ).find(  @cellar_item.wine_detail_id )
    @wine = @wine_detail.wine

    @cellar_item.wine_detail_id = @wine_detail.id
    @cellar_item.capacity = @wine_detail.capacity
    @cellar_item.year = @wine_detail.year
  end

  def new
    @wine_detail = Wines::Detail.includes( :cover, :photos, :statistic,  { :wine => [:style, :winery]} ).find( params[:wine_detail_id].to_i )
    @wine = @wine_detail.wine
    @cellar_item = Users::WineCellarItem.new
    @cellar_item.year = @wine_detail.year
    @cellar_item.number = 1
    @cellar_item.wine_detail_id = @wine_detail.id
    @cellar_item.capacity = @wine_detail.capacity
  end

  def create
    @wine_detail = Wines::Detail.includes( :cover, :photos, :statistic,  { :wine => [:style, :winery]} ).find( params[:wine_detail_id].to_i )
    @wine = @wine_detail.wine

    @cellar = Users::WineCellar.find_by_user_id(current_user.id)
    @cellar ||= Users::WineCellar.create( :user_id => current_user.id, :title => "#{current_user.username}的酒窖", :private_type => Users::WineCellar::PRIVATE_TYPE_PUBLIC )

    @cellar_item = Users::WineCellarItem.new
    @cellar_item.attributes = params[:users_wine_cellar_item]
    @cellar_item.wine_detail_id = @wine_detail.id
    @cellar_item.user_wine_cellar_id = @cellar.id
    @cellar_item.year ||= @wine_detail.year
    @cellar_item.user_id = current_user.id

    ## TODO: 如果这个年份的酒不存在， 则创建这个年份的酒记录 new = old.dup to clone

    if @cellar_item.save
      #flash[:notice] = "成功建立"
      notice_stickie("建立成功.")
      redirect_to :action => :index
    else
      render :action => 'new'
    end
  end

  def update
    @cellar_item = Users::WineCellarItem.where(["id = ? AND user_id = ? ", params[:id], current_user.id ]).first
    @wine_detail = Wines::Detail.includes( :cover, :photos, :statistic,  { :wine => [:style, :winery]} ).find(  @cellar_item.wine_detail_id )
    @wine = @wine_detail.wine

    @cellar_item.capacity = @wine_detail.capacity
    @cellar_item.year = @wine_detail.year

    if @cellar_item.update_attributes(params[:users_wine_cellar_item])
      # flash[:notice] = "成功更新"
      notice_stickie("更新成功.")
      redirect_to :action => :index
    else
      render :action => 'edit'
    end

  end

  def destroy
    @cellar_item = Users::WineCellarItem.where(["id = ? AND user_id = ? ", params[:id], current_user.id ]).first
    if @cellar_item.delete
      # flash[:notice] = "删除成功."
      notice_stickie("删除成功.")
      redirect_to :action => :index
    end
  end

  def add
    if params[:step].to_i == 1
      @search = ::Search.new
      render :template => "mine/cellars/add_step_one"
    elsif params[:step].to_i == 2
      @search = Search.find(params[:id])
       render :template => "mine/cellars/add_step_two"
    end

  end

end
