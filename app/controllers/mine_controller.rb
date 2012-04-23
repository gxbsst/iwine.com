# -*- coding: utf-8 -*-
class MineController < ApplicationController
  before_filter :authenticate_user!

  def index
    ## TODO
    # 喜欢的， 喝过的
    @simple_comments = Wines::Comment.all
    # 藏酒
    @wine_collections = ""
    # 关注的酒
    @wine_follows = ""


    @followers = current_user.followers
    @followings = current_user.followings
    @comments = current_user.comments

  end

  def wish

  end

  def do

  end

  def feeds

  end

  def status

  end
end