# encoding: utf-8
class FriendsController < ApplicationController
  before_filter :authenticate_user!

end
