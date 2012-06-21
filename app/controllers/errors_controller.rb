
class ErrorsController < ApplicationController
  def error_404
  	@title = "404 错误"
  end

  def error_500
  	@title = "500 错误"
  end
end
