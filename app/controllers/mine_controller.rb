# -*- coding: utf-8 -*-
class MineController < ApplicationController
  before_filter :authenticate_user!
  before_filter :get_user

  def index
    ## TODO
    # 喜欢的， 喝过的
    @simple_comments = Wines::Comment.all
    # 藏酒
    @wine_collections = ""
    # 关注的酒
    @wine_follows = ""

  end

  # 关注的酒
  def wine_follows

  end

  # 我的评论
  def comments
    @comments = Wines::Comment.all
  end

  def testing_notes
  end

  def user_follows

  end

  def user_followers

  end
  def wish

  end

  def do

  end

  def feeds

  end

  def status

  end

  private

  def get_user
    @user = current_user
  end

end
