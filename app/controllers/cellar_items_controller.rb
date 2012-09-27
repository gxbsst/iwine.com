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
      if @existing_item = @cellar.items.where(:wine_detail_id => @wine_detail.id).first
        notice_stickie %{不能重复收藏同一只酒，您可以点击<a href="#{edit_cellar_item_path(@cellar, @existing_item, :wine_id => @wine.id)}">修改数目</a>}
        @cellar_item ||= @existing_item
        request.post? ? render(:new) : render(:edit)
      end
    end
end
