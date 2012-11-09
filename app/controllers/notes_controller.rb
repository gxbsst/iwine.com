#encoding: utf-8
class NotesController < ApplicationController
  before_filter :authenticate_user!, :except => [:show]
  
  #包含两部操作
  def new
    case params[:step]
    when "first"
      wine_detail = Wines::Detail.find(params[:wine_detail_id])
      @note = current_user.notes.new
      copy_detail_info(wine_detail)
    end

  end

  def create
    
  end

  def edit
    
  end

  def update
    
  end

  def upload_photo
    #提交照片
    if request.put?
      if params[:note].present?
        @note
      end
    end
  end

  private

  def copy_detail_info(wine_detail)
    @note.name = wine_detail.wine.origin_name
    @note.other_name = wine_detail.wine.name_zh
    if wine_detail.year
      @note.vintage = wine_detail.year.to_s(:year) 
    else
      @note.is_nv  = true
    end
    @note.region_tree_id = wine_detail.wine.region_tree_id
    @note.wine_style_id = wine_detail.wine.wine_style_id
    #TODO 葡萄酒品种
    #@note.grape
    @note.alcohol = wine_detail.alcoholicity.delete("%") if wine_detail.alcoholicity

  end
end