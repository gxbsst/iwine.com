#encoding: utf-8
ActiveAdmin.register Wine do
 config.sort_order = 'updated_at_desc'
  controller do
    def update
      @wine = Wine.find(params[:id])
      region_tree_id = params[:region].values.delete_if{|a| a == ''}.pop
      @wine.region_tree_id = region_tree_id if region_tree_id
      if @wine.update_attributes(params[:wine])
        redirect_to admin_wine_path(@wine)
      else
        render :action => :edit
      end
    end
  end
  form :partial => "form"

  show do |wine|
    attributes_table do
      row "中文名" do
        wine.name_zh
      end

      row "英文名" do
        wine.name_en
      end

      row "原名" do
        wine.origin_name
      end

      row "其他中文名" do
        wine.other_cn_name
      end

      row "官方网址" do
        wine.official_site
      end

      row "种类" do
        wine.style.name if wine.style
      end

      row "所在酒庄" do
        wine.winery.name if wine.winery
      end

      row "区域" do
        wine.region_path_zh if wine.region_tree_id
      end
      row "默认图片" do
        render "admin/share/show_photos", :photos => wine.photos
      end
    end
  end
end
