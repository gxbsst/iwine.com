# encoding: utf-8
module  Wines
  class CommentsController < ApplicationController
    before_filter :authenticate_user!, :except => [:index, :show, :list]
    before_filter :get_wine_detail, :except => [:comment_vote]
    
    def list
      @comments  =  ::Comment.all(:include => [:user],
      # :joins => :votes,
      :joins => "LEFT OUTER JOIN `votes` ON comments.id = votes.votable_id",
      :select => "comments.*, count(votes.id) as votes_count",
      :conditions => ["commentable_id=? AND parent_id IS NULL", @wine_detail.id ], :group => "comments.id",
      :order => "votes_count DESC, created_at DESC" )
      page = params[:params] || 1

      if !(@comments.nil?)
        unless @comments.kind_of?(Array)
          @comments = @comments.page(params[:page]).per(10)
        else
          @comments = Kaminari.paginate_array(@comments).page(params[:page]).per(10)
        end
      end
    end
    # 关注
    def follow
      if request.get?
        @comment = @wine_detail.current_user_follow(current_user)
        @comment = @comment.blank? ?  ::Comment.new : @comment.first
        @comment.do = "follow"
        respond_to do |format|
          format.html { render "create" }
          format.js   { render "create" }
        end
      end

      if request.post?
        @comment = build_comment
        if @comment.save
          # TODO
          # 1. 广播
          # 2. 分享到SNS
          notice_stickie("取消关注成功.")
          redirect_to "/wines/show?wine_detail_id=#{@wine_detail.id}"
        end
      end
    end

    # 评论
    def create
      @comment = ::Comment.new
      @comment.do = "comment"
      if request.post?
        @comment = build_comment
        if @comment.save
          # TODO
          # 1. 广播
          # 2. 分享到SNS
          notice_stickie("评论成功.")
          redirect_to "/wines/show?wine_detail_id=#{@wine_detail.id}"
        end
      end
    end

    # 取消关注
    def cancle_follow
      follow_items = @wine_detail.current_user_follow(current_user)
      return notice_stickie("您还没有有关注该条目.") if follow_items.blank?
      if follow_items.first.update_attribute("deleted_at", Time.now)
        notice_stickie("取消关注成功.")
        redirect_to "/wines/show?wine_detail_id=#{@wine_detail.id}"
      end
    end

    # 有用
    def vote
      @comment = ::Comment.find(params[:comment_id])
      @comment.liked_by current_user
      render :json => @comment.likes.size.to_json
    end

    # 回复评论
    def reply
      @comment = ::Comment.find(params[:comment_id])

      if request.post?
        @comment = ::Comment.find(params[:comment_id])
        @reply_comment = ::Comment.build_from(@wine_detail,
        current_user.id,
        params[:comment][:body],
        :do => "comment")
        @reply_comment.save
        @reply_comment.move_to_child_of(@comment)
        render :json =>  @comment.children.size.to_json
        # respond_to do |format|
        #   format.js { render :json => @comment }
        # end
      end
    end

    private 
    
    def build_comment
      if params[:comment][:do] == "follow"
        @comment = @wine_detail.current_user_follow(current_user)
        @comment = @comment.blank? ?  ::Comment.new : @comment.first
        @comment.attributes =  params[:comment]
        @comment.commentable_type = @wine_detail.class.base_class.name
        @comment.commentable_id = @wine_detail.id
        @comment.point = params[:rate_value]
        @comment.user_id = current_user.id
        return @comment
      end
      @comment = ::Comment.build_from(@wine_detail,
                                    current_user.id ,
                                    params[:comment][:body],
                                    :point => params[:rate_value],
                                    :do => params[:comment][:do],
                                    :is_share => params[:comment][:is_share],
                                    :private => params[:comment][:private])
    end
    
    def get_wine_detail
      @wine_detail = Wines::Detail.includes({ :wine => [:style, :winery]} ).find( params[:wine_detail_id].to_i )
      @wine = @wine_detail.wine
    end
    
  end
end
