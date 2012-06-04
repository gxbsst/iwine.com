# encoding: UTF-8
class FeedbacksController < ApplicationController

  def new
  	build_feedback
  end

  def create
    build_feedback
    if @feedback.save
      notice_stickie("反馈成功.")
    else
      notice_stickie("反馈失败， 请重新创建.")
    end
    redirect_to(request.referer)
  end

  def success
    render :text => "success"
  end

  private
  def build_feedback
    if params.has_key? "feedback_error_feedback" || params[:for] == "error_feedback"
      @feedback = Feedback::ErrorFeedback.new(params[:feedback_error_feedback])
    elsif params.has_key? "feedback_complement_feedback" || params[:for] == "complement_feedback"
      @feedback = Feedback::ErrorFeedback.new(params[:feedback_complement_feedback])
    else
      @feedback = Feedback::NormalFeedback.new(params[:feedback_normal_feedback])
    end
  end
end
