#encoding: utf-8
ActiveAdmin.register Wines::Detail do

  controller do
    def update
      @wines_detail = Wines::Detail.find(params[:id])
      params[:wines_detail].delete('special_comments')
      Wines::SpecialComment.build_special_comment(@wines_detail, params[:special_comment])
      Wines::VarietyPercentage.build_variety_and_percentage(@wines_detail, params[:variety_percentage])
      region_tree_id = params[:region].values.delete_if{|a| a == ''}.pop
      @wines_detail.wine.update_attribute(:region_tree_id,  region_tree_id) unless region_tree_id.blank?
      if @wines_detail.update_attributes(params[:wines_detail])
        redirect_to admin_wines_detail_path(@wines_detail)
      else
        render :action => :edit
      end
    end
  end

  show do |detail|
    attributes_table do
      row "年代" do
        detail.year.to_s
      end
      row "容量" do
        detail.capacity
      end
      row "酒精度" do
        detail.alcoholicity
      end
      row "价格" do
        detail.price
      end
      row "适饮年限" do
        detail.drinkable
      end
      row "中文名" do
        detail.wine.name_zh
      end
      row "英文名" do
        detail.wine.name_en
      end
      row "官方网址" do
        detail.wine.official_site
      end
      row "英文原名" do
        detail.wine.origin_name
      end
      row "其它中文名" do
        detail.wine.other_cn_name
      end
      row "酒的类型" do
        detail.wine.style.name
      end
      row "酒区" do
        detail.region_path_zh(detail.wine.region_tree_id)
      end
      row "酒的品种" do
        detail.show_region_percentage
      end
      row "图片" do
        image_tag(detail.photos.first.image_url(:thumb)) if detail.photos.first
      end
      row "标签" do
        image_tag(detail.photos.label.first.image_url(:middle)) if detail.photos.label.first
      end
    end
  end
  form :partial => "form"
end
