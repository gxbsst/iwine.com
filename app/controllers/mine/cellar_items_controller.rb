# encoding: UTF-8
  class Mine::CellarItemsController < ApplicationController
    before_filter :get_cellar
    before_filter :get_item, :except => [:new, :create, :add]
    before_filter :get_mine
    def edit
      @wine_detail = Wines::Detail.includes( :covers, :photos, :statistic,  { :wine => [:style, :winery]} ).find(  @cellar_item.wine_detail_id )
      @wine = @wine_detail.wine
      @cellar_item.wine_detail_id = @wine_detail.id
      @cellar_item.capacity = @wine_detail.capacity
      @cellar_item.year = @wine_detail.year
    end

    def update
      @wine_detail = Wines::Detail.includes( :covers, :photos, :statistic,  { :wine => [:style, :winery]} ).find(  @cellar_item.wine_detail_id )
      @wine = @wine_detail.wine

      @cellar_item.capacity = @wine_detail.capacity
      @cellar_item.year = @wine_detail.year

      if @cellar_item.update_attributes(params[:users_wine_cellar_item])
        # flash[:notice] = "成功更新"
        notice_stickie("更新成功.")
        redirect_to mine_cellar_path(@cellar)
      else
        render :action => 'edit'
      end

    end

    def destroy
      if @cellar_item.delete
        # flash[:notice] = "删除成功."
        notice_stickie("删除成功.")
       redirect_to mine_cellar_path(@cellar)
      end
    end

    def new
      @wine_detail = Wines::Detail.includes( :covers, :photos, :statistic,  { :wine => [:style, :winery]} ).find( params[:wine_detail_id].to_i )
      @wine = @wine_detail.wine
      @cellar_item = Users::WineCellarItem.new
      @cellar_item.year = @wine_detail.year
      @cellar_item.number = 1
      @cellar_item.wine_detail_id = @wine_detail.id
      @cellar_item.capacity = @wine_detail.capacity
    end

    def create
      @wine_detail = Wines::Detail.includes( :covers, :photos, :statistic,  { :wine => [:style, :winery]} ).find( params[:wine_detail_id].to_i )
      @wine = @wine_detail.wine
      # @cellar = Users::WineCellar.find_by_user_id(current_user.id)
      @cellar ||= current_user.cellar.create(:title => "#{current_user.username}的酒窖", :private_type => Users::WineCellar::PRIVATE_TYPE_PUBLIC )

      @cellar_item = Users::WineCellarItem.new
      @cellar_item.attributes = params[:users_wine_cellar_item]
      @cellar_item.wine_detail_id = @wine_detail.id
      @cellar_item.user_wine_cellar_id = @cellar.id
      @cellar_item.year ||= @wine_detail.year
      @cellar_item.user_id = current_user.id

      ## TODO: 如果这个年份的酒不存在， 则创建这个年份的酒记录 new = old.dup to clone

      if @cellar_item.save
        #flash[:notice] = "成功建立"
        notice_stickie("添加成功.")
        redirect_to mine_cellar_path(@cellar)
      else
        render :action => 'new'
      end
    end

    def add
      if params[:step].to_i == 1
        @search = ::Search.new
        render :template => "mine/cellar_items/add_step_one"
      elsif params[:step].to_i == 2
        @search = Search.find(params[:search_id])
        render :template => "mine/cellar_items/add_step_two"
      end

    end

    private 
      def get_cellar
        @cellar = current_user.cellar
      end

      def get_item
        @cellar_item = @cellar.items.find(params[:id])
      end

  end
