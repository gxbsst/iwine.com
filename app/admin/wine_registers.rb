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
    rescue e
      logger.error(e)
      @wines_register.update_attribute(:status, -1)
      redirect_to admin_wines_registers_path, :notice => "发布出现问题！"
    end
  end

  show do |register|
    attributes_table :name_en, :origin_name, :name_zh, :other_cn_name, :official_site, :vintage, :drinkable_begin, :drinkable_end, :alcoholicity
    attributes_table do
      row "状态" do
        register.show_status
      end
      row "结果" do
        register.show_result
      end
      row "酒区" do
        render "share/region_tree", :region_tree => register.get_region_path(register.region_tree_id)
      end
      row "图片" do
        image_tag(register.photo_name)  unless register.photo_name.blank?
      end
      row "百分比" do
        register.variety_percentage.join ' , '
      end
      row "酒的品种" do
        register.variety_name.join ' , '
      end
      row "酒类"  do
        register.style.name
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
