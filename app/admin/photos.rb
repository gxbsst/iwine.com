# encoding: UTF-8

ActiveAdmin.register Photo do
  config.sort_order = 'updated_at_desc'
  scope :all, :default => true
  scope :approved

  filter :created_at
  filter :audit_status#, :as => :string
  filter :photo_type
  controller do
    def update
      @photo = Photo.find(params[:id])
      if @photo.update_attributes(params[:photo])
        redirect_to admin_photo_path(@photo)

      else
        flash.now[:error] = '编辑失败'
        render :edit
      end
    end
  end

  collection_action :upload_images, :method => :get do
    get_imageable
    @photo = Photo.new
  end

  collection_action :create_images, :method => :post do
    @imageable = get_imageable
    params[:photo][:image].each do |image|
      @photo = @imageable.photos.build
      @photo.image = image
      @photo.user_id = -1 #管理员上传
      if @photo.save
        respond_to do |format|
          format.html{
            render :json => [@photo.to_jq_upload].to_json,
                   :content_type => "text/html",
                   :layout => false
          }
          format.json{
            render :json => [@photo.to_jq_upload].to_json
          }
        end
      else
        render :json => [{:error => "custom_failure"}], :status => 304
      end
    end

  end

  collection_action :edit_images, :method => :get do
    @imageable = get_imageable
    @photos = @imageable.photos
  end

  collection_action :update_images, :method => :put do
    @imageable = get_imageable
    #begin
      destroy_photos(params[:photos][:destroy])
      update_photos(params[:photos])
      redirect_to "#{root_url}#{callback_url(params[:imageable_type], params[:imageable_id])}"
    #rescue Exception => e
    #  flash.now[:error] = "更新图片失败！"
    #  render :edit_images, :imageable_type => params[:imageable_type], :imageable_id => params[:imageable_id]
    #end

  end

  form :partial => 'form'

  show do |p|
    attributes_table do
      row '图片' do
        image_tag p.image_url(:thumb)
      end
      row "宽" do
        p.width
      end
      row "高" do
        p.height
      end
      row '相册' do
        p.album.name if p.album
      end
      row '介绍' do
        p.intro
      end
      row '类型' do
        show_photo_type(p.photo_type)
      end
      row '状态' do
        photo_status(p.audit_status)
      end
    end
  end
  
  index do
    column :id
    # column(:album_id, :album, :sortable => :album_id)
    column "图片" do |photo|
      image_tag photo.image_url(:thumb)
    end
    column :width
    column :height
    column :intro
    column :photo_type do |photo|
      show_photo_type(photo.photo_type)
    end
    column :audit_status do |photo|
      photo_status(photo.audit_status)
    end
    column :created_at
    default_actions
  end

end

def get_imageable
  if params[:imageable_type] && params[:imageable_id]
    imageable_type = params[:imageable_type] == 'Detail' ? "Wines::Detail" : params[:imageable_type]
    @imageable = imageable_type.constantize.find params[:imageable_id]
  else
    redirect_to "/admin"
  end
end

def callback_url(imageable_type, imageable_id)
  url_type = case imageable_type
               when 'Winery'
                 "wineries"
               when 'Wine'
                 "wines"
               when 'Detail'
                 'wines_details'
             end
  "admin/#{url_type}/#{imageable_id}"
end

def destroy_photos(photo_ids)
  if photo_ids.present?
    photo_ids.each do |photo_id|
      Photo.find(photo_id).update_attribute(:deleted_at, Time.now)
    end
  end
end

def update_photos(photos)
  photos.each do |id, photo|
    @photo = @imageable.photos.where("id = ?", id).first
    next unless @photo
    @photo.update_attributes(photo)
  end
end

def show_photo_type(value)
  type = [ "正常", "标志", "封面"]
  type[value.to_i]
end

def photo_status(value)
  type = ['已提交', '已发布', '被拒绝']
  type[value.to_i]
end
