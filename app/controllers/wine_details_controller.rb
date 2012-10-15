# encoding: UTF-8
class WineDetailsController < ApplicationController
  before_filter :authenticate_user!, :except => [:index, :show, :comments, :owners, :followers]
  before_filter :set_current_user
  before_filter :get_wine_detail, :only => [:show, :owners, :followers, :photo_upload]
  before_filter :get_follow_item, :only => [:show]
  before_filter :find_register, :only => [:edit, :update]
  before_filter :find_winery, :only => [:update]
  before_filter :check_region_tree, :only => :create
  before_filter :check_edit_register, :only => [:edit, :update]
  before_filter :check_and_create_albums, :only => [:photo_upload]
  
  def index
    @title = "酒"
    # @wines = Wines::Detail.includes(:wine, :cover).order("created_at ASC").page params[:page] || 1
    @timelines = Wines::Detail.timeline_events

    page = params[:page] || 1

    if !(@timelines.nil?)
      unless @timelines.kind_of?(Array)
        @timelines = @timelines.page(page).per(30)
      else
        @timelines = Kaminari.paginate_array(@timelines).page(page).per(30)
      end
    end

  end

  # Wine Profile
  def show
    @wine             = @wine_detail.wine
    @comments         = @wine_detail.all_comments(:limit => 6)
    @owners           = @wine_detail.owners(:limit => 4)
    @followers        = @wine_detail.followers(:limit => 11)
    @photos           = @wine_detail.all_photos.limit(6)
    @covers           = @wine_detail.show_covers
    @title = @wine_detail.name
  end

  #搜索要添加的酒
  def add
    if params[:step].to_i == 1
      @search = ::Search.new
      render :template => "wine_details/add_step_one"
    elsif params[:step].to_i == 2
      @search = Search.find(params[:id])
      server = HotSearch.new
      @entries = server.all_entries(@search.keywords)
      @all_wines = @entries['wines']
      page = params[:page] || 1
      if @all_wines.present?
        unless @all_wines.kind_of?(Array)
          @wines = @all_wines.page(page).per(10)
        else
          @wines = Kaminari.paginate_array(@all_wines).page(page).per(10)
        end
      end
      render :template => "wine_details/add_step_two"
    end
  end

  def edit
  end

  def update
    params[:wines_register].delete('special_comments')
    Wines::SpecialComment.build_special_comment(@register, params[:special_comment])
    @register.result = 1 #设置为一，用户无法再编辑
    if @register.update_attributes(params[:wines_register])
      # redirect_to wine_path(@register)
      render "add_success"
    else
      render :action => :edit
    end

  end

  #添加新酒
  def new
    if params[:wine_id]
      @read_only = true
      @wine = Wine.find(params[:wine_id])
      #保存酒的基本信息
      @register = Wines::Register.create(
          :name_en => @wine.name_en,
          :official_site => @wine.official_site,
          :vintage => @wine.details.releast_detail.first.year,
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
        notice_stickie t("notice.save_success")
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
      redirect_to edit_wine_path @register
    else
      render :action => "new"
    end
  end
  
  # 关注者
  def followers
    @wine      = @wine_detail.wine
    @followers = @wine_detail.followers
    
    if !(@followers.nil?)
      unless @followers.kind_of?(Array)
        @followers = @followers.page(params[:page]).per(8)
      else
        @followers = Kaminari.paginate_array(@followers).page(params[:page]).per(8)
      end
    end
  end

  # 拥有者
  def owners
    @wine   = @wine_detail.wine
    @owners = @wine_detail.owners
    if !(@owners.nil?)
      unless @owners.kind_of?(Array)
        @owners = @owners.page(params[:page]).per(8)
      else
        @owners = Kaminari.paginate_array(@owners).page(params[:page]).per(8)
      end
    end
    
  end

  # 添加到酒窖
  def add_to_cellar
     redirect_to new_cellar_item_path(current_user.cellar.id, :wine_detail_id => params[:id] )
  end

  #上传酒成功
  def add_success
    
  end

  #上传照片
  def photo_upload
    @photo = @wine_detail.photos.new
    @wine = @wine_detail.wine
  end
  private

  def set_current_user
    User::current_user = current_user || 0
  end

  def get_wine_detail
    #如果是成功上传酒就不需要@wine_detail
    @wine_detail = Wines::Detail.includes(:label, :photos).find(params[:id]) unless params[:register_success]
  end

  def check_edit_register
    if @register.result.to_i == 1
      notice_stickie t("notice.wine_detail.check_edit_register")
      # redirect_to mine_wine_path(@register)
      render "add_success"
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
  
  #根据用户输入查找匹配的第一个酒庄
  def find_winery
    if params[:winery] 
      if params[:winery][:name_en]
        @winery = Winery.where("name_en = ? or origin_name = ? ", params[:winery][:name_en], params[:winery][:name_en]).first
      end
      if !@winery && params[:winery][:name_zh]
        name_zh_arr = change_name_zh(params[:winery][:name_zh])
        name_zh_arr.each do |name_zh|
          @winery = Winery.where("name_zh = ?", name_zh).first
          break if @winery
        end
      end

      #赋值
      @register.winery_id = @winery.id if @winery
    end
  end

  def change_name_zh(name_zh)
    if name_zh.present?
      name_zh_arr = name_zh.gsub(";", "；").split("；")#处理英文";"并转换化为数组
    end
  end

  # 登录用户是否关注酒
  def get_follow_item
    if !user_signed_in? 
      nil
    else
      if @follow_item = (@wine_detail.is_followed_by? current_user)
        @follow_item 
      else
        nil
      end
    end
  end

end
