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
      #redirect_to edit_verify_path @verify_form
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
    if @verify_form.update(params[:verify])
      render "success"
    else
      render "edit"
    end
    #redirect_to edit_verify_path(@verify_form.verify)
  end

  def success
    @title = "用戶认证"
  end

  protected

  def get_user
    @user ||= current_user
  end

  def init_verify_form(user)
    VerifyForm.init(user)
  end

end
