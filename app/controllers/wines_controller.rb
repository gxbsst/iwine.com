# encoding: UTF-8
class WinesController < ApplicationController

  def register
     @register = Wines::Register.new
     if request.post?
       @register.attributes = params[:wines_register]
       @register.variety_name = params[:wines_register][:variety_name_value].to_json
       @register.variety_percentage = params[:wines_register][:variety_percentage_value].to_json
       if @register.save
         flash[:notice] = '保存成功'
       end
     end
  end

end
