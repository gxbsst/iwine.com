#encoding: utf-8

ActiveAdmin.register Comment, :as => "CustomerComment" do
  filter :user, :as => :check_boxes
  filter :is_share, :as => :check_boxes
  controller do
  	def destroy
  	  @comment = Comment.find(params[:id])
  	  if @comment.update_attribute(:deleted_at, Time.now)
  	  	flash[:notice] = "删除成功。"
  	  else
  	  	flash[:error] = "删除失败！"
  	  end
  	  redirect_to admin_customer_comments_path
  	end

  	def index
  	  index! do |format|
        @customer_comments = Comment.unscoped.where("parent_id is null").page(params[:page])
        format.html
      end
  	end

  end  
  member_action :reapprove, :method => :get do
    @comment = Comment.unscoped.find(params[:id])
  	if @comment.update_attribute(:deleted_at, nil)
  	  #更改评论数目
  	  @comment.commentable.class.increment_counter(:comments_count, @comment.commentable_id)
  	  User.increment_counter(:comments_count, @comment.user_id)
  	  flash[:notice] = "发布成功！"
    else
  	  flash[:error] = "发布失败！"
    end
    redirect_to admin_customer_comments_path
  end

  index do
  	column :id
  	column :commentable_type
  	column :body
  	column '评论人' do |comment|
      comment.user.username
    end
  	column :deleted_at
  	column :is_share
  	# default_actions
  	column "管理" do |comment|
  	  if comment.deleted_at
  	    link_to "还原", reapprove_admin_customer_comment_path(comment)
  	  else
        link_to "删除", admin_customer_comment_path(comment), :method => :delete
      end
  	end
  end

  def recount_comment(comment)

  end
end
