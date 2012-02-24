class WinesController < ApplicationController

  def register
     @register = Wines::Register.new
  end

end
