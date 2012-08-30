# encoding: UTF-8
  class CellarItemsController < ApplicationController
    before_filter :authenticate_user!
    before_filter :get_current_user
    before_filter :get_cellar
    before_filter :get_item, :except => [:new, :create, :add]

    def edit
      @wine_detail = Wines::Detail.includes( :covers, :photos, { :wine => [:style, :winery]} ).find(  @cellar_item.wine_detail_id )
      @wine = @wine_detail.wine
      @cellar_item.wine_detail_id = @wine_detail.id
    end

    def update
      @wine_detail = Wines::Detail.includes( :covers, :photos, { :wine => [:style, :winery]} ).find(  @cellar_item.wine_detail_id )
      @wine = @wine_detail.wine

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
      @wine_detail = Wines::Detail.includes( :covers, :photos, { :wine => [:style, :winery]} ).find( params[:wine_detail_id] )
      @wine = @wine_detail.wine
      @cellar_item = Users::WineCellarItem.new(:number => 1, 
                                               :wine_detail_id => @wine_detail.id, 
                                               :location => current_user.city,
                                               :private_type => false)
    end

    def create
      @wine_detail = Wines::Detail.includes( :covers, :photos, { :wine => [:style, :winery]} ).find( params[:wine_detail_id] )
      @wine = @wine_detail.wine
      # @cellar = Users::WineCellar.find_by_user_id(current_user.id)
      @cellar ||= current_user.cellar.create(:title => "#{current_user.username}的酒窖", :private_type => Users::WineCellar::PRIVATE_TYPE_PUBLIC )

      @cellar_item = Users::WineCellarItem.new
      @cellar_item.attributes = params[:users_wine_cellar_item]
      @cellar_item.wine_detail_id = @wine_detail.id
      @cellar_item.user_wine_cellar_id = @cellar.id
      @cellar_item.user_id = current_user.id

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

  end
