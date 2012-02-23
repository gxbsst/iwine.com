class WinesController < ApplicationController

  def register
     @wine_register = Register.new
  end

end
