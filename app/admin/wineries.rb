# encoding: utf-8
ActiveAdmin.register Winery do

  controller do
    #helper :winery

    def edit
      @winery = Winery.find(params[:id])
      @winery.info_items.build if @winery.info_items.blank? # for accepts_nested_attributes_for
      @winery.photos.build(:album_id => current_admin_user.id) if @winery.photos.blank?
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
    attributes_table :name_en, :name_zh, :address, :official_site, :email, :cellphone, :fax
    attributes_table do
      row "区域" do
        winery.region_path_zh(winery.region_tree_id)
      end
      row "LOGO" do
        image_tag(winery.logo_url(:thumb))
      end
      row "图片" do
        render "show_photos", :photos => winery.photos
      end
      row "酒庄信息" do
        render "show_info_items", :info_items => winery.info_items
      end
      row "第三方微博网址" do
        render "show_winery_config", :config => winery.config
      end
    end
  end

  form :partial => "form"
end
