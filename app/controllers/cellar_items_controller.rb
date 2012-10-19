# encoding: UTF-8
class CellarItemsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :get_current_user
  before_filter :get_cellar
  before_filter :get_item, :except => [:new, :create, :add]
  before_filter :get_wine, :only => [:create, :new, :edit, :update]
  before_filter :get_wine_detail, :only => [:update, :create]
  before_filter :check_uniqueness_detail, :only => [:update, :create]
  def edit
  end

  def update
    @cellar_item.wine_detail = @wine_detail
    if @cellar_item.update_attributes(params[:users_wine_cellar_item])
      notice_stickie t("notice.update_success")
      redirect_to cellars_user_path(@user, @cellar)
    else
      render :action => 'edit'
    end

  end

  def destroy
    if @cellar_item.destroy
      notice_stickie t("notice.destroy_success")
      redirect_to cellars_user_path(@user, @cellar)
    end
  end

  def new

    @cellar_item = Users::WineCellarItem.new(:number => 1, 
                                            :location => current_user.city,
                                            :private_type => false)
    # 当确定加入某年代红酒直接生成年代
    if params[:wine_detail_id]
      wine_detail = Wines::Detail.find(params[:wine_detail_id])
      @cellar_item.year = wine_detail.year if wine_detail.year.present?
      @cellar_item.is_nv = wine_detail.is_nv if wine_detail.is_nv.present?
    end
  end

  def create
    @cellar ||= current_user.cellar.create(:title => "#{current_user.username}的酒窖", :private_type => Users::WineCellar::PRIVATE_TYPE_PUBLIC )

    @cellar_item = @cellar.items.build
    @cellar_item.attributes = params[:users_wine_cellar_item]
    @cellar_item.wine_detail = @wine_detail
    @cellar_item.user = current_user

    ## TODO: 如果这个年份的酒不存在， 则创建这个年份的酒记录 new = old.dup to clone

    if @cellar_item.save
      notice_stickie t("notice.cellar_item.create_success")
      redirect_to cellars_user_path(@user, @cellar)
    else
      render :action => 'new'
    end
  end

  def add
    if params[:step].to_i == 1
      @search = ::Search.new
      render  "add_step_one"
    elsif params[:step].to_i == 2
      @search = Search.find(params[:search_id])
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
      render "add_step_two"
    end
  end

  private 
    def get_cellar
      @cellar = @user.cellar
    end

    def get_item
      @cellar_item = @cellar.items.find(params[:id])
    end

    def get_wine
      @wine = Wine.find(params[:wine_id])
    end

    def get_wine_detail
      @wine_detail = @wine.copy_detail(@wine_detail, 
                                       params[:users_wine_cellar_item][:is_nv], 
                                       params[:users_wine_cellar_item]['year(1i)'])
    end
    
    def check_uniqueness_detail
      @existing_item = @cellar.items.where(:wine_detail_id => @wine_detail.id).first
      if (request.post? && @existing_item) || (request.put? && @existing_item && @existing_item != @cellar_item)
        notice_stickie %{不能重复收藏同一只酒，您可以点击<a href="#{edit_cellar_item_path(@cellar, @existing_item, :wine_id => @wine.id)}">修改数目</a>}
        @cellar_item ||= @existing_item
        request.post? ? render(:new) : render(:edit)
      end
    end
end
