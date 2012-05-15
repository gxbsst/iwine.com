# encoding: UTF-8
class SearchesController < ApplicationController

  def new
    @search = Search.new
  end

  def create
    @search = Search.create!(params[:search])
    redirect_to add_mine_cellar_items_path(current_user.cellar.id, :step => 2, :search_id => @search.id)
  end

  def search_wines
    @search = Search.create!(params[:search])
    redirect_to add_mine_wines_path(:step => 2, :id => @search.id)
  end

  def hot_words 
    server = HotSearch.new
    words = server.hot_words params[:word]

    wines = words['wines']
    wineries = words['wineries']

    render :json => { 'wines' => wines[0..4] , 'wineries' => wineries[0..4] }
  end

  def hot_entries

  end
end