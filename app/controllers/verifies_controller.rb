# encoding: utf-8
class VerifiesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :get_user

  def new
    @verify_form = init_verify_form(@user)
    redirect_to edit_verify_path(@verify_form.verify) unless @verify_form.new_record?
  end

  def create
    @verify_form = VerifyForm.new(params[:verify_form])
    @verify_form.user = @user
    if @verify_form.save
      render :text => "coolll"
    else
      render "new"
    end
  end

  def edit
    @verify_form = init_verify_form(@user)
    redirect_to new_verify_path if @verify_form.new_record?
  end

  def update
    @verify_form = init_verify_form(@user)
    @verify_form.update(params[:verify_form])
    redirect_to edit_verify_path(@verify_form.verify)
  end

  protected

  def get_user
    @user ||= current_user
  end

  def init_verify_form(user)
    VerifyForm.init(user)
  end

end
