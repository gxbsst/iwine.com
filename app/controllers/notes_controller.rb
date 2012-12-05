# encoding: utf-8
class NotesController < ApplicationController

  before_filter :authenticate_user!, :except => [:show, :index]
  before_filter :update_note_from_app, :only => [:app_edit]
  before_filter :find_note, :only => [:edit, :update, :upload_photo]

  def index 
   date = params[:modified_date]
   result      = Notes::NotesRepository.all(date)
   return render_404('') unless result['state']
   @notes = Notes::HelperMethods.build_all_notes(result)
  end 

  def show
   result      = Notes::NotesRepository.find(params[:id])
   return render_404('') if (!result['state'] || result['data']['statusFlag'].to_i != Note::STATUS_FLAG[:published])
   @note = Notes::NoteItem.new(result['data'])
   @user       = User.find(result['data']['uid'])
   notes_result = Notes::NotesRepository.find_by_user(result['data']['uid'], @note.note.id)
   @user_notes = Notes::HelperMethods.build_user_notes(notes_result)  if notes_result['state']
   wine_result =  Notes::NotesRepository.find_by_wine(@note.wine.vintage, @note.wine.sName, @note.wine.oName, @note.note.id, 5,  @note.note.id)
   @wine_note_users = Notes::HelperMethods.build_wine_notes(wine_result)  if wine_result['state'] 
  end

  def add
    if params[:step].to_i == 1
      @search = ::Search.new
      render :template => "notes/add_step_one"
    elsif params[:step].to_i == 2
      @search = Search.find(params[:id])
      server = HotSearch.new
      @entries = server.all_entries(@search.keywords)
      @all_wines = @entries['wines']
      page = params[:page] || 1
      if @all_wines.present?
        unless @all_wines.kind_of?(Array)
          @wines = @all_wines.page(page).per(10)
        else
          @wines = Kaminari.paginate_array(@all_wines).page(page).per(10)
        end
      end
      render :template => "notes/add_step_two"
    end
    
  end
  #接收app_note_id 或者 wine_detail_id
  def new
    @note = current_user.notes.new
    @note.user_agent = NOTE_DATA['note']['user_agent']['local']
    @note.status_flag = NOTE_DATA['note']['status_flag']['submitted']
    @note.uuid = SecureRandom.uuid
    if params[:wine_detail_id].present?     #来自 wine_detail profile
      wine_detail = Wines::Detail.find(params[:wine_detail_id])
      @note.init_basic_data_from_wine_detail wine_detail
    elsif params[:app_note_id].present? #来自 note profile
      result = Notes::NotesRepository.find(params[:app_note_id])
      @note.init_basic_data_from_app(result['data'])
    end
    if @note.save
      redirect_to edit_note_path(@note, :step => "first")
    else
      error_stickie t("notice.failure")
      redirect_to request.referer || root_url
    end
  end

  #暂时弃用
  # def create
  #   @note.rating = params[:rate_value].to_i
  #   @note.attributes = params[:note]
  #   if @note.save && @note.post_form
  #     #是否设置为草稿
  #     if params[:status] == 'submitted'
  #       notice_stickie t('notice.note.submitted_success')
  #       redirect_to edit_note_path(@note, :step => "first")
  #     else
  #       redirect_to edit_note_path(@note, :step => "second")
  #     end
  #   else
  #     error_stickie t("notice.failure")
  #     render :action => :new
  #   end
  # end

  #接收来自app的id 对应于本地app_note_id
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
  
  #接收app_note_id
  def publish
    note = current_user.notes.where(:app_note_id => params[:id]).first
    if note.publish
      notice_stickie t("notice.note.publish_success")
      redirect_to note_path(note.app_note_id)
    else
      notice_stickie t("notice.note.publish_failure")
      redirect_to notes_user_path(current_user)
    end
  end
 
  def destroy
    note = current_user.notes.where(:app_note_id => params[:id]).first
    if note.try :delete_note
      notice_stickie t("notice.destroy_success")
      redirect_to destroy_success_redirect_to
    else
      notice_stickie t("notice.destroy_failure")
      redirect_to destroy_failure_redirect_to(note) 
    end
  end

  def update
    if params[:step] == "first"
      @note.rating = params[:rate_value]
    elsif params[:step] == "second"
      union_clarity_and_tannin_nature
    end
    set_status_flag
    
    #验证comemnt 不能为空
    @note.attributes = params[:note]
    unless @note.valid?
      error_stickie ("请完善您的输入信息.")
      render 'edit_first'
      return
    else
       @note.save  # 保存到数据库
       if @note.post_form # 传到API
         if params[:step] == "first"
           step = params[:status] == "submitted" ? "first" : "second"
           redirect_to edit_note_path(@note, :step => step)
         else
           if params[:status] == "submitted"
             redirect_to notes_user_path(current_user)
           else
             redirect_to note_path(@note.app_note_id)
           end
         end
       else
         error_stickie t("notice.failure")
         render "edit_#{params[:step]}"
       end
    end

    #if @note.save && (@note.post_form)
    #  if params[:step] == "first"
    #    step = params[:status] == "submitted" ? "first" : "second"
    #    redirect_to edit_note_path(@note, :step => step)
    #  else
    #    if params[:status] == "submitted"
    #      redirect_to notes_user_path(current_user)
    #    else
    #      redirect_to note_path(@note.app_note_id)
    #    end
    #  end
    #else
    #  error_stickie t("notice.failure")
    #  render "edit_#{params[:step]}"
    #end
  end

  def upload_photo
    #提交照片
    if request.put?
      if params[:note].present?
        @note.update_attribute(:photo, params[:note][:photo])
      end
      redirect_to edit_note_path(@note, :step => :first)
    end

    #剪裁图片
    if request.post?
      if params[:note][:crop_x].present?
        @note.attributes = params[:note]
        @note.update_attribute(:photo, params[:photo])
      end
      redirect_to edit_note_path(@note, :step => :first)
    end
    # #编辑照片
    if request.get?
      respond_to do |format|
        format.js
      end
    end

  end

  def trait
    @categories = WineTrait.where(:parent_id => 0)
    @traits = WineTrait.where('parent_id !=0')
    if params[:ids].present?
      params[:ids].split(',').each do |id|
        @traits.each do |trait|
          trait.mark_select  if trait.id == id.to_i
        end
      end
    end
  end

  def color
    @categories = WineColor.where(:parent_id => 0)
    @traits = WineColor.where('parent_id !=0')
    if params[:ids].present?
      params[:ids].split(',').each do |id|
        @traits.each do |trait|
          trait.mark_select  if trait.id == id.to_i
        end
      end
    end

    render 'trait'
  end

  private
  
  #来自user profile 跳转到 user profile, 来自 note profile 就跳转到 瀑布流
  def destroy_success_redirect_to
    params[:user_profile] ? notes_user_path(current_user) : notes_path
  end

  def destroy_failure_redirect_to(note)
    params[:user_profile] ? notes_user_path(current_user) : note_path(note.app_note_id)
  end

  def set_status_flag
    if params[:status] == "next" && params[:step] == "second"
      @note.status_flag = NOTE_DATA['note']['status_flag']['published']
    else
      #发布状态不能再次设置为草稿状态。
      if @note.status_flag != NOTE_DATA['note']['status_flag']['published']
        @note.status_flag = NOTE_DATA['note']['status_flag']['submitted']
      end
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

  def update_note_from_app
    result = Notes::NotesRepository.find(params[:id])
    if result['state']
      #检查该app_note的user和当前user是不是同一个人
      if current_user.try(:id) != result['data']['uid']
        render_404('')
      else
        @note = current_user.notes.where(:uuid => result['data']['notesId']).
            first_or_initialize(:user_id => current_user.id, :app_note_id => params[:id])
        @note.sync_data(result['data'])
      end
    else
      render_404('') #处理note被删除或者网络问题无法加载note的错误
    end
  end

  def find_note
    @note = current_user.notes.find(params[:id])
  end

end