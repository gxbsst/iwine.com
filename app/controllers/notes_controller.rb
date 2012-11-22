#encoding: utf-8
class NotesController < ApplicationController
  before_filter :authenticate_user!, :except => [:show]
  before_filter :update_note_from_app, :only => [:app_edit]
  before_filter :find_note, :only => [:edit, :update]
  #包含两部操作
  def new
    wine_detail = Wines::Detail.find(params[:wine_detail_id])
    @@note = current_user.notes.new
    @@note.status_flag = NOTE_DATA['note']['status_flag']['submitted']
    @@note.user_agent = NOTE_DATA['note']['user_agent']['local']
    copy_detail_info(wine_detail)
    @note = @@note unless @note
  end

  def create
    @note = @@note
    @note.rating = params[:rate_value].to_i - 1
    @note.status_flag = NOTE_DATA['note']['status_flag']['submitted']
    @note.attributes = params[:note]
    if @note.save && @note.post_form
      #是否设置为草稿
      if params[:status] == 'submitted'
        notice_stickie t('notice.note.submitted_success')
        redirect_to edit_note_path(@note, :step => "first")
      else
        redirect_to edit_note_path(@note, :step => "second")
      end
    else
      notice_stickie t("notice.failure")
      render :action => :new
    end
  end

  def show
    result      = Notes::NotesRepository.find(params[:id])
    return render_404('') unless result['state']
    @note = Notes::NoteItem.new(result['data'])
    @user       = User.find(result['data']['uid'])
    notes_result = Notes::NotesRepository.find_by_user(result['data']['uid'], @note.note.id)
    @user_notes = Notes::HelperMethods.build_user_notes(notes_result)  if notes_result['state']
    wine_result =  Notes::NotesRepository.find_by_wine(@note.wine.vintage, @note.wine.sName, @note.wine.oName, @note.note.id)
    @wine_note_users = Notes::HelperMethods.build_wine_notes(wine_result)  if wine_result['state']
  end

  def app_edit
    render "edit_first"
  end


  def edit
    if params[:step] == "first"
      render "edit_first"
    elsif params[:step] == "second"
      parse_clarity_and_tannin_nature
      render "edit_second"
    end
  end

  def update
    if params[:step] == "first"
      @note.rating = params[:rate_value]
    elsif params[:step] == "second"
      union_clarity_and_tannin_nature
    end
    set_status_flag
    #保存
    if @note.update_attributes(params[:note]) && (@note.post_form)
      if params[:step] == "first"
        step = params[:status] == "submitted" ? "first" : "second"
        redirect_to edit_note_path(@note, :step => step)
      else
        if params[:status] == "submitted"
          render :text => "用户列表"
        else
          redirect_to note_path(@note.app_note_id)
        end
      end
    else
      notice_stickie t("notice.failure")
      render "edit_#{params[:step]}"
    end
  end

  def upload_photo
    @note = current_user.notes.find(params[:note_id]) if params[:note_id].present?
    @note = @@note unless @note
    #提交照片
    if request.put?
      if params[:note].present?
        @note.update_attribute(:photo, params[:note][:photo])
      end
      redirect_to @note.new_record? ? new_note_path : edit_note_path(@note, :step => :first)
    end

    #剪裁图片
    if request.post?
      if params[:note][:crop_x].present?
        @note.attributes = params[:note]
        @note.update_attribute(:photo, params[:photo])
      end
      redirect_to edit_note_path(@note, :step => :first)
    end
    @@note = @note
    # #编辑照片
    if request.get?
      respond_to do |format|
        format.js
      end
    end

  end

  private

  def set_status_flag
    if params[:status] == "submitted"
      @note.status_flag = NOTE_DATA['note']['status_flag']['submitted']
    else
      @note.status_flag = NOTE_DATA['note']['status_flag']['published']
    end
  end

  def parse_clarity_and_tannin_nature
    @note.appearance_clarity_a = @note.appearance_clarity.to_i/10
    @note.appearance_clarity_b = @note.appearance_clarity.to_i%10
    @note.palate_tannin_nature_a = @note.palate_tannin_nature.to_i/100
    @note.palate_tannin_nature_b = @note.palate_tannin_nature.to_i%100/10
    @note.palate_tannin_nature_c = @note.palate_tannin_nature.to_i%100%10
  end

  def union_clarity_and_tannin_nature
    @note.appearance_clarity = params[:note][:appearance_clarity_a].to_i * 10 + params[:note][:appearance_clarity_b].to_i
    @note.palate_tannin_nature = params[:note][:tannin_nature_a].to_i * 100 + params[:note][:tannin_nature_b].to_i * 10 +
      params[:note][:tannin_nature_c].to_i
    @note.palate_tannin_level = params[:note][:palate_tannin_level].to_i #不选择时设置为零。
  end

  def copy_detail_info(wine_detail)
    @@note.name = wine_detail.wine.origin_name
    @@note.other_name = wine_detail.wine.name_zh
    if wine_detail.year
      @@note.vintage = wine_detail.year.to_s(:year)
    else
      @@note.is_nv  = true
    end
    @@note.region_tree_id = wine_detail.wine.region_tree_id
    @@note.wine_style_id = wine_detail.wine.wine_style_id
    @@note.wine_detail_id = wine_detail.id
    #TODO 葡萄酒品种
    #@@note.grape
    @@note.alcohol = wine_detail.alcoholicity.delete("%") if wine_detail.alcoholicity
  end

  def update_note_from_app
    result = Notes::NotesRepository.find(params[:id])
    if result['state']
      check_app_user(result['data']['uid'])
      @note = current_user.notes.where(:uuid => result['data']['notesId']).
        first_or_initialize(:user_id => current_user.id, :app_note_id => params[:id])
      @note.sync_data(result['data'])
    end
  end

  #检查该app_note的user和当前user是不是同一个人
  def check_app_user(uid)
    if current_user.try(:id) != uid
      notice_stickie t('notice.no_ability')
      redirect_to note_path(params[:id])
    end
  end

  def find_note
    @note = current_user.notes.find(params[:id])
  end
end