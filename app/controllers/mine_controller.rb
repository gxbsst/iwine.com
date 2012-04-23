class MineController < ApplicationController
  before_filter :authenticate_user!
  
  def index

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