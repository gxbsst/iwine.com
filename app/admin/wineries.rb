# encoding: utf-8
ActiveAdmin.register Winery do

  controller do
    #helper :winery

    def edit
      @winery = Winery.find(params[:id])
      @winery.info_items.build if @winery.info_items.blank? # for accepts_nested_attributes_for
      @winery.photos.build(:album_id => current_admin_user.id)    if @winery.photos.blank?
    end

    def update
      @winery = Winery.find(params[:id])
      @winery.save_region_tree(params[:region])
      if @winery.update_attributes(params[:winery])
        redirect_to admin_winery_path(@winery)
      else
        render :edit
      end

    end

    def new
      @winery = Winery.new
      @winery.info_items.build
      @winery.photos.build(:album_id => current_admin_user.id)
    end

    def create
      @winery = Winery.new(params[:winery])
      @winery.save_region_tree(params[:region])
      if @winery.save
        redirect_to admin_winery_path(@winery)
      else
        render :new
      end
    end

  end

  show do |winery|
    attributes_table do
      row "英文名" do
        winery.name_en
      end
      row "中文名" do
        winery.name_zh
      end
      row "地址" do
        winery.address
      end
      row "官方网址" do
        winery.official_site
      end
      row "Email" do
        winery.email
      end
      row "联系电话" do
        winery.cellphone
      end
      row "传真" do
        winery.fax
      end
      row "第三方微博网址" do
        render "show_winery_config", :config => winery.config
      end
      row "区域" do
        winery.region_path_zh
      end
      row "LOGO" do
        image_tag(winery.logo_url(:thumb)) unless winery.logo_url.include?("default")
      end
      row "图片" do
        render "admin/share/show_photos", :photos => winery.photos
      end
      row "酒庄信息" do
        render "show_info_items", :info_items => winery.info_items
      end
    end
  end

  index do
    column("ID", :id){|winery| link_to winery.id, admin_winery_path(winery)}
    column :name_zh
    column :name_en
    column "地区", :region_tree_id, :region_tree
    column "LOGO" do |winery|
      image_tag(winery.logo_url(:thumb)) unless winery.logo_url.include?("default")
    end
    column "介绍" do |winery|
      items = winery.info_items
      if items.present?
        "#{items.first.title}  #{items.first.description}"
      end
    end
  end

  form :partial => "form"
end
