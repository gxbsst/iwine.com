# encoding: UTF-8
class SearchesController < ApplicationController
  before_filter :get_recommend_users, :only => [:results, :search_wines, :winery]

  def new
    @search = Search.new
  end

  def create
    @search = Search.create!(params[:search])
    redirect_to add_cellar_items_path(current_user.cellar.id, :step => 2, :search_id => @search.id)
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

    if ( @words['wines'].length + @words['wineries'].length ) > 0 
      render :layout => false
    else
      render :text => ''
    end
  end

  def hot_entries

  end

  def winery
    @title = "搜索酒庄"
    server = HotSearch.new
    @entries = server.all_entries( params[:word])
    @wineries = @entries['wineries']
    page = params[:page] || 1
    if !(@wineries.nil?)
      unless @wineries.kind_of?(Array)
        @wineries = @wineries.page(page).per(10)
      else
        @wineries = Kaminari.paginate_array(@wineries).page(page).per(10)
      end
    end
  end

  def wine 
    server = HotSearch.new
    @entries = server.all_entries(params[:word])
    @wines= @entries['wines']
    @results = @wines.inject([]) do |mem, item| 
      wine = {}
      details = item.details
      wine_detail = details.first
      years = details.collect {|detail| [detail.year.year, "/wines/#{detail.slug}"] }
      wine[:name_zh] = years.first.first.to_s + item.name_zh 
      wine[:origin_name] = years.first.first.to_s + item.origin_name 
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

  private

  def get_recommend_users
    if current_user
      @recommend_users = User.no_self_recommends(5, current_user.id)
    else
      @recommend_users = User.recommends(5)
    end
  end
end
