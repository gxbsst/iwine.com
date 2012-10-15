#encoding: utf-8
namespace :photo do

  # ## 上传酒和酒庄的图片
  task :upload_all_photo => [:upload_wine_photo, :upload_winery_photo] do

  end
  desc "上传酒的图片,发布酒后执行此操作。"
  task :upload_wine_photo => :environment do
    puts "=============== upload_wine_photo begin"
    require "csv"
    require "fileutils"
    file_directories = Rails.root.join("lib", "tasks", "data", "wine", "*.csv")
    Dir.glob(file_directories).each do |csv_file|
      csv = CSV.read(csv_file)
      csv.each_with_index do |item, index|
        begin
          next if index == 0 || item[0].blank?#跳过标题
          photo_directory = Rails.root.join("lib", "tasks", "data", "wine", "wine_photos", item[0])
          wine = Wine.where("name_en = ? ", to_ascii(item[1])).first
          if wine
            save_default_photos(wine, photo_directory)
            save_detail_photos(wine, photo_directory, item[9])
          end
        rescue Exception => e
          puts e
        end
      end
    end
  end

  desc "上传酒庄的图片，清洗完酒庄数据开始执行此操作。"
  task :upload_winery_photo => :environment do
    puts "=============== upload_winery_photo begin"
    require "csv"
    require "fileutils"
    file_directories = Rails.root.join("lib", "tasks", "data", "winery", "*.csv")
    Dir.glob(file_directories).each do |csv_file|
      csv = CSV.read(csv_file)
      csv.each_with_index do |item, index|
        next if index == 0 #跳过标题
        photo_directory = Rails.root.join("lib", "tasks", "data", "winery", "winery_photos", item[0])
        begin
          winery = Winery.where("name_en = ? ", to_ascii(item[1])).first
          if winery && item[0].present? #酒庄和图片必须存在
            #logo
            logo_path = Dir.glob("#{photo_directory}/logo.*").first
            if logo_path
              winery.update_attribute("logo", open(logo_path))
            end
            #其他图片
            Dir.glob("#{photo_directory}/*").each do |file|
              next if file.include?("logo")
              photo = winery.photos.build
              photo.photo_type  =  get_photo_type(file)
              photo.image = open(file) #需要单独赋值          
              photo.save
              photo.approve_photo
              puts "winery_id #{winery.id}  photo_id #{photo.id}  #{photo.photo_type}"
            end

            #删除已经保存的图片
            #FileUtils.rm_r("#{photo_directory}")
          end
        rescue Exception => e
          puts e
        end
      end
      #删除已经清楚过的数据
      #FileUtils.rm(csv_file)
    end

  end

  def to_ascii(string)
    string.to_s.force_encoding('utf-8').to_ascii_brutal
  end

  def get_photo_type(file)
    type = file.include?("cover") ? APP_DATA['photo']['photo_type']['cover'] : (file.include?("label") ? APP_DATA['photo']['photo_type']['label'] : 0)
    return type
  end

  def save_default_photos(wine, photo_directory)
    file_arr = Dir.glob("#{photo_directory}/*default*") #获取所有默认图片
    return  if file_arr.blank? || wine.photos.present? #有照片则不再上传
    file_arr.each do |file|
      photo = wine.photos.create!(
          :photo_type => get_photo_type(file),
          :image => open(file)
      )
      photo.approve_photo
      puts "wine #{photo.id}"
    end
  end

  def save_detail_photos(wine, photo_directory, year)
    file_arr = Dir.glob("#{photo_directory}/*#{year}*") #获取所有此年代得图片
    return if file_arr.blank?
    detail = get_detail(wine, year)
    return if !detail || detail.photos.present? #有照片则不再上传
    file_arr.each do |file|
      photo = detail.photos.create!(
        :photo_type => get_photo_type(file),
        :image => open(file)
      )
      #发布图片
      photo.approve_photo
      puts "wine_detail #{photo.id}"
    end
  end

  def get_detail(wine, year)
    if year.to_s == "NV"
      detail = wine.details.where("year is null and is_nv = 1").first
    else
      detail = wine.details.where("year = ?", DateTime.parse("#{year}-01-01")).first
    end
    return detail
  end
end
