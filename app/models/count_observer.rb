# encoding: utf-8
class CountObserver < ActiveRecord::Observer
  observe :comment, :photo, Users::WineCellarItem, Wines::Detail, ActsAsVotable::Vote

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
    end
  end

  private

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

  #上传照片操作
  def increment_photos_count model, target_id, target_type_class
    target_type_class.increment_counter :photos_count, target_id
    increment_user_count model
  end

  def decrement_photos_count model, target_id, target_type_class
    target_type_class.decrement_counter :photos_count, target_id
    decrement_user_count model
  end

  #评论或者关注
  def increment_comments_count model, target_id, target_type_class
    case model.do
      when "follow"
        target_type_class.increment_counter :followers_count, target_id
      when "comment"
        target_type_class.increment_counter :comments_count, target_id
    end
    increment_user_count model
  end

  def decrement_comments_count model, target_id, target_type_class
    case model.do
      when "follow"
        target_type_class.decrement_counter :followers_count, target_id
      when "comment"
        target_type_class.decrement_counter :comments_count, target_id
    end
    decrement_user_count model
  end


  def increment_user_count model
    User.increment_counter "#{change_to_pluralize model}_count", model.user_id
  end

  def decrement_user_count model
    User.decrement_counter "#{change_to_pluralize model}_count", model.user_id
  end

  def change_to_pluralize model
    name = get_model_name model
    name.downcase.pluralize
  end

  def get_model_name model
    model.class.name.include?("Comment") ? model.class.superclass.name : model.class.name
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
      when "Vote"
        [model.voteable_id, "Vote", model.voteable_type]
     end
    return [target_id, target_type, target_type_class.constantize]
  end
end
