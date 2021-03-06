# encoding: UTF-8
class SearchesController < ApplicationController
  before_filter :get_recommend_users, :only => [:results, :search_wines, :winery, :wine]
  
  def new
    @search = Search.new
  end

  def create
    @search = Search.create!(params[:search])
    redirect_to add_cellar_items_path(current_user.cellar.id, :step => 2, :search_id => @search.id)
  end
  
  def search_note_wines
    @title = "搜索酒款"
    @search = Search.create!(params[:search])
    redirect_to add_notes_path(:step => 2, :id => @search.id)
  end

  def search_wines
    @title = "搜索酒"
    @search = Search.create!(params[:search])
    redirect_to add_wines_path(:step => 2, :id => @search.id)
  end

  def search_user
    @title = "搜寻好友"
    @search = Search.create!(params[:search])
    redirect_to search_friends_path(:id => @search.id)
  end

  def suggestion
    if params[:word].blank?
      render :json => { 'wines' =>  [] , 'wineries' => [] }
      return
    end
    server = HotSearch.new
    @words = server.hot_words params[:word]
    if @words['wines'].present? || @words['wineries'].present?
      render :layout => false
    else
      render :text => ''
    end
  end

  def hot_entries

  end

  # for Events
  def event_wine
    server = HotSearch.new
    @entries = server.all_entries(params[:word])
    @wines= @entries['wines']
    if @wines.present?
      @results = @wines.inject([]) do |mem, item| 
        wine = {}
        details = item.details
        wine_detail = details.first
        years = details.collect {|detail| [detail.show_year, "/wines/#{detail.slug}", detail.id] }
        item.name_zh ||= item.origin_name
        year = years.first.first.to_s
        wine[:wine_detail_id] = wine_detail.id
        wine[:name_zh] = item.name_zh 
        wine[:year] = year
        wine[:origin_name] = item.origin_name 
        ## TODO: write a method to get wine_detail cover
        wine[:image_url] = wine_detail.get_cover_url(:thumb)
        wine[:all_years] = years
        wine[:url] = "/wines/#{wine_detail.slug}"
        mem << wine 
      end
      respond_to do |format|
        format.html  
        format.json {render :json => @results}
      end
    else
      respond_to do |format|
        format.html  
        format.json {render :json => ''}
      end
    end
  end

  def results
    @title = "搜索"
    server = HotSearch.new
    @entries = server.all_entries( params[:word])
    @all_wines = @entries['wines']
    @wineries = @entries['wineries']
    page = params[:page] || 1
    if @all_wines.present?
      unless @all_wines.kind_of?(Array)
        @wines = @all_wines.page(page).per(10)
      else
        @wines = Kaminari.paginate_array(@all_wines).page(page).per(10)
      end
    end
    

    @all_tab = @wine_tab = ''
    @tab = params[:tab] || ''
    
    if params[:tab] == 'wine' 
      @wine_tab = 'current'
    else
      @all_tab = 'current'
    end

  end

  # 搜索酒庄
  def winery
    @title = "搜索酒庄"
    server = HotSearch.new
    @wineries = server.search_winery(params[:word])
    page = params[:page] || 1
    if !(@wineries.nil?)
      unless @wineries.kind_of?(Array)
        @wineries = @wineries.page(page).per(10)
      else
        @wineries = Kaminari.paginate_array(@wineries).page(page).per(10)
      end
    end
  end

  # 搜索酒
  def wine
    @title = "搜索酒"
    server = HotSearch.new
    @wines = server.search_wine(params[:word])
    page = params[:page] || 1
    if !(@wines.nil?)
      unless @wines.kind_of?(Array)
        @wines = @wines.page(page).per(10)
      else
        @wines = Kaminari.paginate_array(@wines).page(page).per(10)
      end
    end
  end

  private 
  def get_recommend_users
    if current_user 
      # @recommend_users = User.no_self_recommends(5, current_user.id)
      @recommend_users = current_user.remove_followings_from_user User.all :conditions =>  "id <> "+ current_user.id.to_s , :limit => 5
    else
      @recommend_users = User.recommends(5)
    end
  end
end
