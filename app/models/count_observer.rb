# encoding: utf-8
class CountObserver < ActiveRecord::Observer
  observe :comment, :photo, Users::WineCellarItem, Wines::Detail, ActsAsVotable::Vote, :friendship, :album

  def after_create model
    target_id, target_type, target_type_class = get_target model
    case target_type
      when "Photo"
        increment_photos_count model, target_id, target_type_class
      when "Comment"
        increment_comments_count model, target_id, target_type_class
      when "Wines::Detail"
        increment_cellar_items_count model, target_id, target_type_class
      when "Winery"
        increment_wine_details_count model, target_id, target_type_class
      when "Vote"
        increment_votes_count target_id, target_type_class
      when 'Friendship'
        increment_follows_count model
      when "Album"
        increment_albums_count model
    end
  end

  def after_destroy model
    target_id, target_type, target_type_class = get_target model
    case target_type
      when "Photo"
        decrement_photos_count model, target_id, target_type_class
      when "Comment"
        decrement_comments_count model, target_id, target_type_class
      when "Wines::Detail"
        decrement_cellar_items_count model, target_id, target_type_class
      when "Winery"
        decrement_wine_details_count model, target_id, target_type_class
      when "Vote"
        decrement_votes_count target_id, target_type_class
      when 'Friendship'
        decrement_follows_count model
      when "Album"
        decrement_albums_count model
    end
  end

  # only for cancel_follow
  def after_update model
    if get_model_name(model) == "Comment"
      target_id, target_type, target_type_class = get_target model
      if model.parent_id.blank?
        case model.do
          when "follow"
            target_type_class.decrement_counter :followers_count, target_id
          when "comment"
            target_type_class.decrement_counter :comments_count, target_id
        end
        decrement_user_count model
      end
    end
  end
  private

  #相册
  def increment_albums_count model
    User.increment_counter :albums_count, model.created_by
  end

  def decrement_albums_count model
    User.decrement_counter :albums_count, model.created_by
  end

  #关注用户
  def increment_follows_count model
    User.increment_counter :followers_count, model.user_id
    User.increment_counter :followings_count, model.follower.id
  end

  def decrement_follows_count model
    User.decrement_counter :followers_count, model.user_id
    User.decrement_counter :followings_count, model.follower.id
  end
  #对评论”有用", 对照片“赞"
  def increment_votes_count target_id, target_type_class
    target_type_class.increment_counter :votes_count, target_id
  end

  def decrement_votes_count target_id, target_type_class
    target_type_class.decrement_counter :votes_count, target_id
  end

  #上传酒
  def increment_wine_details_count model, target_id, target_type_class
    target_type_class.increment_counter :wines_count, target_id #update wines_count of winery
    User.increment_counter :wines_count, model.user_id # update wines_count of user
  end

  def decrement_wine_details_count model, target_id, target_type_class
    target_type_class.decrement_counter :wines_count, target_id
    User.decrement_counter :wines_count, model.user_id
  end

  #加入酒窖操作
  def increment_cellar_items_count model, target_id, target_type_class
    target_type_class.increment_counter :owners_count, target_id  #update owners_count of wine_detail
    Users::WineCellar.increment_counter :items_count, model.user.cellar.id if model.user_id != -1 #update items_count 0f user_wine_cellar
  end

  def decrement_cellar_items_count model, target_id, target_type_class
    target_type_class.decrement_counter :owners_count, target_id
    Users::WineCellar.decrement_counter :items_count, model.user.cellar.id if model.user_id != -1
  end

  #上传照片操作(需要特别注意上传wine的photo时，用户photos_count目前暂不修改)
  def increment_photos_count model, target_id, target_type_class
    return if model.imageable_type == "Wine" #wine的photo不计数
    target_type_class.increment_counter :photos_count, target_id
    User.increment_counter :photos_count, model.user_id
  end

  def decrement_photos_count model, target_id, target_type_class
    return if model.imageable_type == "Wine"
    target_type_class.decrement_counter :photos_count, target_id
    User.decrement_counter :photos_count, model.user_id
  end

  #评论或者关注
  def increment_comments_count model, target_id, target_type_class
    if model.parent_id.blank? #parent_id 不为空是回复，数目不变
      case model.do
        when "follow"
          target_type_class.increment_counter :followers_count, target_id
        when "comment"
          target_type_class.increment_counter :comments_count, target_id
      end
      increment_user_count model
    end
  end

  def decrement_comments_count model, target_id, target_type_class
    if model.parent_id.blank?
      case model.do
        when "follow"
          target_type_class.decrement_counter :followers_count, target_id
        when "comment"
          target_type_class.decrement_counter :comments_count, target_id
      end
      decrement_user_count model
    end
  end


  def increment_user_count model
    User.increment_counter get_count_name(model), model.user_id
  end

  def decrement_user_count model
    User.decrement_counter get_count_name(model), model.user_id
  end

  def get_count_name model
    if model.do == "comment"
      "comments_count"
    elsif model.do == "follow"
      model.commentable_type == "Winery" ? "winery_followings_count" : "wine_followings_count"
    end
  end

  def get_model_name model
    model_name = model.class.name
    model_name.include?("Comment") && model_name != "Comment" ? model.class.superclass.name : model_name
  end

  def get_target model
    name = get_model_name model
    target_id, target_type, target_type_class = case name
      when "Photo"
        [model.imageable_id, "Photo", model.imageable_type]
      when "Comment"
        [model.commentable_id, "Comment", model.commentable_type]
      when "Users::WineCellarItem"
        [model.wine_detail_id, "Wines::Detail", "Wines::Detail"]
      when "Wines::Detail"
        [model.wine.winery_id, "Winery", "Winery"]
      when "ActsAsVotable::Vote"
        [model.votable_id, "Vote", model.votable_type]
      when "Friendship" #关注某人
        [model.user_id, "Friendship", "User"]
      when "Album" #相册
        [model.user_id, "Album", "Album"]
     end
    return [target_id, target_type, target_type_class.constantize]
  end
end
