class Mine::AlbumsController < ApplicationController
  before_filter :authenticate_user!

end