# encoding: UTF-8
class SearchesController < ApplicationController

  def new
    @search = Search.new
  end

  def create
    @search = Search.create!(params[:search])
    redirect_to add_cellar_items_path(current_user.cellar.id, :step => 2, :search_id => @search.id)
  end

  def search_wines
    @search = Search.create!(params[:search])
    redirect_to add_users_wines_path(:step => 2, :id => @search.id)
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
    server = HotSearch.new
    @page = params[:page].to_i || 1
    if @page < 1 
      @page = 1
    end
    @entries = server.all_entries( params[:word] , @page )
    @wineries = @entries['wineries']
  end

  def results
    server = HotSearch.new
    @page = params[:page].to_i || 1
    if @page < 1 
      @page = 1
    end
    @entries = server.all_entries( params[:word] , @page )
    @all_tab = @wine_tab = ''
    @tab = params[:tab] || ''
    
    if params[:tab] == 'wine' 
      @wine_tab = 'current'
    else
      @all_tab = 'current'
    end
  end
end