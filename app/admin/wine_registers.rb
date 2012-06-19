# encoding: UTF-8
ActiveAdmin.register Wines::Register do

  filter :style, :as => :check_boxes
  filter :status

  controller do
    def update
      @wines_register = Wines::Register.find(params[:id])
      params[:wines_register].delete('special_comments')
      Wines::SpecialComment.build_special_comment(@wines_register, params[:special_comment])
      @wines_register.result = 1 #设置为一，用户无法再编辑
      region_tree_id = params[:region].values.delete_if{|a| a == ''}.pop
      @wines_register.region_tree_id = region_tree_id unless region_tree_id.blank?
      if @wines_register.update_attributes(params[:wines_register])
        redirect_to admin_wines_register_path(@wines_register)
      else
        render :action => :edit
      end
    end
  end

  member_action :approve, :method => :get do
    @wines_register = Wines::Register.find(params[:id])
    begin
      Wine.transaction do
        if @wines_register.status == 1
          redirect_to admin_wines_registers_path, :notice => "已经发布过，请勿重复发布"
        else
          @wines_register.approve_wine
          redirect_to admin_wines_registers_path, :notice => "发布成功"
        end
      end
    rescue Exception => e
      logger.error(e)
      @wines_register.update_attribute(:status, -1)
      redirect_to admin_wines_registers_path, :notice => "发布出现问题！"
    end
  end

  show do |r|
    attributes_table do
      row "英文名" do
        r.name_en
      end
      row "中文名" do
        r.name_zh
      end
      row '其它中文名' do
        r.other_cn_name
      end
      row '原名' do
        r.origin_name
      end
      row '年代' do
        r.show_vintage
      end
      row '适饮年限' do
       "#{r.drinkable_begin.to_s} - #{r.drinkable_end.to_s}"
      end
      row '酒精度' do
        r.alcoholicity
      end
      row "状态" do
        r.show_status
      end
      row "结果" do
        r.show_result
      end
      row "酒区" do
        r.region_path_zh
      end
      row "图片" do
        image_tag(r.photo_name)  unless r.photo_name.blank?
      end
      row "百分比" do
        r.variety_percentage.join ' , '
      end
      row "酒的品种" do
        r.variety_name.join ' , '
      end
      row "酒类"  do
        r.style.name
      end
    end
  end

  form :partial => 'form'

  index do
    column :name_en
    column :name_zh
    column :vintage
    default_actions
    column "管理" do |register|
      register.status.to_i != 1 ? link_to( "#{register.status.to_i == 0 ? '发布' : '发布失败，重新发布'}", approve_admin_wines_register_path(register)) : "已发布"
    end
  end
end
