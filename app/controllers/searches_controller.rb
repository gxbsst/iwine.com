# encoding: UTF-8
class SearchesController < ApplicationController

  def new
    @search = Search.new
  end

  def create
    @search = Search.create!(params[:search])
    redirect_to add_mine_cellar_path(current_user.cellar.id, :step => 2, :search_id => @search.id)
  end

  def search_wines
    @search = Search.create!(params[:search])
    redirect_to mine_wines_add_path(:step => 2, :id => @search.id)
  end
end
