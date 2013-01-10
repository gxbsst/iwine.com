# encoding: utf-8
class VerifiesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :get_user

  def index
    @title = "用戶认证"
  end

  def new
    @title = "用戶认证"
    @verify_form = init_verify_form(@user)
    redirect_to edit_verify_path(@verify_form.verify) unless @verify_form.new_record?
  end

  def create
    @title = "用戶认证"
    return redirect_to new_verify_path if @user.apply_verify?
    @verify_form = VerifyForm.new(params[:verify])
    @verify_form.user = @user
    if @verify_form.save
      render "success"
    else
      @verify_form = init_verify_form(@user)
      render "new"
    end
  end

  def edit
    @title = "用戶认证"
    @verify_form = init_verify_form(@user)
    redirect_to new_verify_path if @verify_form.new_record?
  end

  def update
    @title = "用戶认证"
    @verify_form = init_verify_form(@user)
    if @verify_form.verify.accepted?
      error_stickie "您的审核已经通过， 不能重复提交"
      return redirect_to edit_verify_path(@verify_form)
    end
    render @verify_form.update(params[:verify]) ? "success" : "edit"
  end

  def success
    @title = "用戶认证"
  end

  def identify_photo
    version = params[:version]
    source_file_name, source_file_path = source_file(version, :identify_photo)
    target_file_directory, target_file_path = target_file(source_file_name, :identify_photo)
    # After deploied on server, a CRON job will clean up these links every 30 minutes.
    symlink(source_file_path, target_file_path)
    redirect_to get_photo_path(source_file_name, target_file_directory)
  end

  def vocation_photo
    version = params[:version]
    source_file_name, source_file_path = source_file(version, :vocation_photo)
    target_file_directory, target_file_path = target_file(source_file_name, :vocation_photo)
    # After deploied on server, a CRON job will clean up these links every 30 minutes.
    symlink(source_file_path, target_file_path)
    redirect_to get_photo_path(source_file_name, target_file_directory)
  end

  protected

  def get_user
    @user ||= current_user
  end

  def init_verify_form(user)
    VerifyForm.init(user)
  end

  def source_file(version, photo)
    if version
      file_path = @user.verify.send(:"#{photo.to_s}_url", version.to_sym)
      file_name = @user.verify.send(:photo).versions[version.to_sym].file.filename
    else
      file_path = @user.verify.send(:"#{photo.to_s}_url")
      file_name = @user.verify.send(photo).file.filename
    end
    return file_name, file_path
  end

  def target_file(file_name, photo)
    directory = "uploads/verify/#{photo.to_s}/#{@user.verify.slug}_#{Time.now.to_i}"
    target_path = Rails.root.join('public', directory)
    create_dir(target_path)
    return directory, target_path.join(file_name)
  end

  def create_dir(target_path)
    FileUtils.mkdir target_path unless File.directory? target_path.join("#{@user.verify.slug}_#{Time.now.to_i}")
  end

  def symlink(source, target)
    unless File.symlink(source, target) == 0
      render :text => "Sorry, system is busy now. Please try again several seconds later."
      return false
    end
  end

  def get_photo_path(source_file_name, target_file_directory)
    "/#{target_file_directory}/#{source_file_name}"
  end

end
