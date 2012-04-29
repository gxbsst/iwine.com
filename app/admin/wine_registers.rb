ActiveAdmin.register Wines::Register do
  filter :style, :as => :check_boxes
  filter :status

  controller do
    def update
      @wines_register = Wines::Register.find(params[:id])
      params[:wines_register].delete('special_comments')
      Wines::SpecialComment.build_special_comment(@wines_register, params[:special_comment])
      @wines_register.result = 1 #设置为一，用户无法再编辑
      @wines_register.region_tree_id = params[:region].values.delete_if{|a| a == ''}.pop if params[:region]
      if @wines_register.update_attributes(params[:wines_register])
        redirect_to admin_wines_register_path(@wines_register)
      else
        render :action => :edit
      end
    end
  end

  show do |register|
    attributes_table :name_en, :origin_name, :name_zh, :other_cn_name, :official_site, :vintage, :drinkable_begin, :drinkable_end, :alcoholicity, :status, :result
    attributes_table do
      row :region_tree_id do
        register.get_region_path(register.region_tree_id)
      end
      row :photo_name do
        image_tag(register.photo_name)  unless register.photo_name.blank?
      end
      row :variety_percentage do
        register.variety_percentage.join ' , '
      end
      row :variety_name do
        register.variety_name.join ' , '
      end
      row :wine_style_id  do
        register.style.name
      end
      row "special_comment" do
        register.special_comments.each do |s|
          "#{s.name} #{s.score} #{s.drinkable_begin.strftime('%Y') if s.drinkable_begin} - #{s.drinkable_end.strftime('%Y') if s.drinkable_end}"
        end
      end
    end
  end

  form :partial => 'form'


  index do
    column :name_en
    column :name_zh
    column :vintage
    default_actions
  end

end
