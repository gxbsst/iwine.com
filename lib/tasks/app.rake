#encoding: UTF-8
namespace :app do
  
  # ## 执行此命令会按顺序执行以下所有命令, 注意先后顺序[默认数据，酒庄数据，酒的数据]
  task :init_whole_data => [:init_default_data, 
                            :init_wineries, 
                            :init_wines_data] do
  end

  # ##初始化基本数据
  task :init_default_data => [:init_style_and_region_data, 
                              :init_varieties, 
                              :init_region_tree] do

  end

  # ##加载并发布酒
  task :init_wines_data => [:upload_all_wines, :new_approve_wines] do

  end
  
  # ##矫正酒的品种数据错误。

  task :improve_variety_percent => :environment do
    puts "================ upload_all_wines task begin"
    require 'csv'
    file_directories = Rails.root.join("lib", "tasks","data", "wine", "*.csv")
    logger = Logger.new Rails.root.join("log", "variety_percent.log")
    logger.info "===============#{Time.now}======================"
    logger.info "name_en variety percent year(detail)"
    Dir.glob(file_directories).each do |csv_file|
      puts "*************** begin load #{csv_file} *****************"
      csv = CSV.read(csv_file)
      csv.each_with_index do |item, index|
        begin
          #年代
          next if item[9].blank? #年代为空(没有任何值)跳过此条目
          if item[9].strip == "NV"
            wine_detail = Wines::Detail.where(" name_en = ? and is_nv = 1 ", to_ascii(item[1].strip)).joins(:wine).first
          else
            wine_detail = Wines::Detail.where(" name_en = ? and year like ? ", to_ascii(item[1].strip), "#{item[9]}%").joins(:wine).first
          end
            
          # if [3496, 7718, 4563].include?(wine_detail.try(:id))
          if wine_detail
            #酒类品种及百分比处理
            variety_name, variety_percentage = get_variety_percentage(item[12])
            Wines::VarietyPercentage.build_variety_percentage(variety_name, variety_percentage, wine_detail, logger) if variety_name.present?
          end
        rescue Exception => e
          logger.info e
        end
      end
    end
    logger.close
  end

  desc "TODO"
  task :init_style_and_region_data => :environment do
    puts "================ init_style_and_region_data task begin"
    require 'csv'
    parent_styles = [
      ['Still Wine', '静态葡萄酒'],
      ['Sparkling', '起泡酒'],
      ['Fortified', '加强酒'],
      ['Sweet Wine', '甜酒'],
      ['Others', '其它']
    ]
    styles = [
      ['Red', '红葡萄酒', 'Table Wine'],
      ['White', '白葡萄酒', 'Table Wine'],
      ['Rose', '粉红葡萄酒', 'Table Wine'],
      ['Red Sparkling', '起泡红葡萄酒', 'Sparkling'],
      ['White Sparkling', '起泡白葡萄酒', 'Sparkling'],
      ['Rose Sparkling', '起泡粉红葡萄酒', 'Sparkling'],
      ['Port', '波特酒', 'Fortified'],
      ['Sherry', '雪利酒', 'Fortified'],
      ['Other Fortified', '其它加强酒', 'Fortified']

    ]

    #
    # ## 导入酒类表
    #导入主类别葡萄酒
    parent_styles.each do |s|
      w = Wines::Style.
        where("name_en = ? and name_zh =? ", s[0], s[1]).
        first_or_create(:name_en => s[0], :name_zh => s[1])
      puts "wine_style #{w.id}"
    end

    #导入子类葡萄酒
    styles.each do |s|
      w = Wines::Style.
        where("name_en = ? and name_zh = ?", s[0], s[1]).
        first_or_initialize(:name_en => s[0], :name_zh => s[1])
      parent = Wines::Style.find_by_name_en(s[2])
      w.parent = parent if parent
      w.save
    end
    #
    # ## 导入中国地区表
    regions = CSV.read("#{Rails.root}/lib/tasks/data/region.csv")
    regions.each do |r|
      region = Region.find_or_create_by_parent_id_and_region_name_and_region_type(r[1], r[2], r[3].to_i)
      puts "region #{region.id}"
    end
  end

  desc "TODO"
  task :init_varieties => :environment do
    puts "================ init_varieties task begin==================="
    require 'csv'
    #
    # ## 导入酒庄
    varieties = CSV.read("#{Rails.root}/lib/tasks/data/wine_variety_i18n.csv")
    varieties.each do |v|
      begin
        unless v[2].blank?
          v[2] = v[2].force_encoding 'utf-8'
          pinyin = v[2].contains_cjk? ? HanziToPinyin.hanzi_to_pinyin(v[2]) : ''
        end
        Wines::Variety.create(:name_zh => v[2], :name_en => v[0].force_encoding('utf-8').to_ascii_brutal, :origin_name => v[0], :pinyin => pinyin) if Wines::Variety.find_by_origin_name(v[0]).nil?
      rescue Exception => e
        puts e
      end

    end
  end

  desc "将数据填进wine_registers表中"
  task :upload_all_wines => :environment do
    puts "================ upload_all_wines task begin"
    require 'csv'
    require "fileutils"
    ## 导入酒和详细信息
    logger = Logger.new Rails.root.join("log", "register.log")
    logger.info "===============#{Time.now}======================"
    logger.info "name_en year [error]"
    file_directories = Rails.root.join("lib", "tasks","data", "wine", "*.csv")
    Dir.glob(file_directories).each do |csv_file|
      puts "*************** begin load #{csv_file} *****************"
      csv = CSV.read(csv_file)
      csv.each_with_index do |item, index|
        begin
          #匹配不以零开头的四位数字或者NV
          register_year = item[9].to_s.strip
          unless register_year =~ /^([1-9]\d{3}|NV)$/
            logger.info "#{item[1]}, #{item[9]}" 
            next
          end
          #转换数据类型
          item.collect{|i| i.to_s.force_encoding('utf-8')}
          #查找region_tree
          region_tree_id = Wines::RegionTree.get_region_tree_id(to_ascii(item[5]))
          #处理适饮年限
          drinkable_begin, drinkable_end = get_drinkable_time(item[10])
          #酒类品种及百分比处理
          variety_name, variety_percentage = get_variety_percentage(item[12])
          #get wine_style_id
          wine_style = Wines::Style.where("name_zh = ? ", item[4]).first
          #中文名处理
          name_zh_arr = change_name_zh_to_arr item[2]
          name_en = to_ascii(item[1].to_s.strip)
          #确定NV和vintage必须有一个
          if register_year == 'NV'
            register = Wines::Register.where("name_en = ? and vintage is not null", name_en).first
          else
            register = Wines::Register.where("name_en = ? and is_nv = 1", name_en).first
          end
          if register #如果存在说明有重复现象
            logger.info "#{item[1]}, #{item[9]}"
            next
          end
          #查找register
          if register_year == "NV"
            wine_register = Wines::Register.where("name_en = ? and is_nv = 1", name_en)
          else
            wine_register = Wines::Register.where("name_en = ? and vintage = ?", name_en, Time.local(register_year))
          end
          register = wine_register.first_or_create!(
            :origin_name => item[1].strip.force_encoding('utf-8'),
            :name_en => name_en,
            :name_zh => first_name_zh(name_zh_arr),                                   #去除第一个当做名字
            :other_cn_name => other_name_zh(name_zh_arr),
            :vintage => register_year == "NV" ? nil : Time.local(register_year),
            :is_nv => register_year == "NV" ? true : false,
            :official_site => to_utf8(item[3]).gsub(/http:\/\//, ''),
            :wine_style_id => wine_style ? wine_style.id : nil,
            :region_tree_id => region_tree_id,
            :winery_origin_name => item[7].present? ? item[7].strip : nil,
            :winery_name_en => item[7].present? ? to_ascii(item[7].strip) : nil,
            :drinkable_begin => drinkable_begin.present? ? Time.local(drinkable_begin) : nil,
            :drinkable_end => drinkable_end.present? ? Time.local(drinkable_end) : nil,
            :alcoholicity => item[11],
            :variety_percentage => variety_percentage,
            :variety_name => variety_name,
            :status => 0, #0表示此条记录没有发布
            :result => 0,
            :user_id => -1, #-1说明是程序填充的数据
            :capacity => item[13],
            :description => to_ascii(item[18])
          )
          puts register.id
          build_special_comment(register, {"RP" => item[14], "JR" => item[16]})
        rescue Exception => e
          puts e
          logger.info e
        end
      end
    end
    logger.close
  end

  #发布酒
  desc "将wine_registers中的数据分别导入到对应的wine 和wine_details表中"

  task :approve_wines => :environment do
    require 'csv'
    # 文件复制
    require 'fileutils'
    #检查图片路径
    Dir.mkdir "#{Rails.root}/public/uploads/photo" unless Dir.exist? "#{Rails.root}/public/uploads/photo"
    Dir.mkdir "#{Rails.root}/public/uploads/photo/wine" unless Dir.exist? "#{Rails.root}/public/uploads/photo/wine"

    Wines::Register.where("status = ? ", 0).each do |wine_register|
      begin
        Wine.transaction do
          wine_register.approve_wine
          puts wine_register.id
        end
      rescue Exception => e
        wine_register.update_attribute(:status, -1)
        puts e
      end
    end
  end

  desc "（新版）将wine_registers中的数据分别导入到对应的wine 和wine_details表中"
  task :new_approve_wines => :environment do
    puts "================ new_approve_wines task begin"
    logger = Logger.new Rails.root.join("log", "approve_wine.log")
    Wines::Register.where("status = 0").each do|register|
      begin
        Wine.transaction do
          wine_detail_id = register.new_approve_wine(logger)
          puts "#{wine_detail_id} #{register.vintage}"
        end
      rescue Exception => e
        register.update_attribute(:status, -1) #发布失败
        logger.info e
      end
    end
    logger.close

  end

  desc "加载region_tree"
  task :init_region_tree => :environment do
    puts "================ init_region_tree task begin"
    require 'csv'
    # TODO: “请修改下面的路径”
    file_directories = Rails.root.join("lib/tasks/data/region_tree/region_tree/*.csv")
    Dir.glob(file_directories).each do |csv_file|
      puts "begin load #{csv_file}"
      csv = CSV.read(csv_file)
      csv.each do |item|
        item.collect{|i| i.to_s.force_encoding('utf-8')}
        #是奇数说明包含doc
        doc = item.size.odd? ? item.pop : nil
        item_to_hash = Hash[*item]
        parent = nil #搜索parent时，如果搜到nil则终止搜索
        level = 1
        item_to_hash.each do |key, value|
          unless value.blank?
            ascii_value = to_ascii(value)
            name_zh = key.blank? ? ascii_value : key
            # TODO:
            # 如果处理以下
            # 1. 法国,France,波尔多,Bordeaux,梅多克,Médoc,梅多克,Médoc
            # 2. 添加一个字段， 保存原生文字，如:RhÃ´ne Valley, name_en 保存 RhA´ne Valley
            # 转换方法: "Moulis/ Moulis-en-MÃ©doc".to_ascii_brutal => https://github.com/tomash/ascii_tic
            parent_condition = parent ? " parent_id = #{parent} " : " parent_id is null "
            region = Wines::RegionTree.where("name_en = ? and level = ? and #{parent_condition}", ascii_value, level).first
            region = Wines::RegionTree.create(:doc => to_ascii(doc),
                                              :name_zh => name_zh,
                                              :name_en => ascii_value,
                                              :origin_name => value,
                                              :parent_id => parent,
                                              :scope => 0,
                                              :tree_left => 0,
                                              :tree_right => 0,
                                              :level => level) if region.blank?
            parent = region.id
            level = level + 1
            puts region.id
          end
        end
      end

    end
  end

  task :init_wineries => :environment do
    puts "================ init_wineries task begin"
    require 'csv'
    require 'fileutils'

    file_directory = Rails.root.join("lib", "tasks", "data", "winery", "*.csv")
    Dir.glob(file_directory).each do |csv_file|
      puts "begin load #{csv_file}"
      csv  = CSV.read(csv_file)
      csv.each_with_index do |item, index|
        item.collect{|i| i.to_s.force_encoding('utf-8')} #转换数据类型
        # find region_tree_id
        region_tree_id = Wines::RegionTree.get_region_tree_id(item[12].to_s.to_ascii_brutal)
        name_zh_arr = change_name_zh_to_arr(item[2])
        Winery.transaction do
          begin
            name_en = item[1].to_s.to_ascii_brutal
            winery = Winery.where("name_en = ?", name_en).
                first_or_create!(
                :name_en => name_en,
                :origin_name => item[1],
                :name_zh => first_name_zh(name_zh_arr),
                :other_cn_name => other_name_zh(name_zh_arr),
                :cellphone => item[3].to_s.gsub(" ", ''),
                :fax => item[4],
                :email => item[5],
                :official_site => item[6].to_s.gsub(/http:\/\//, ''),
                :address => item[7].to_s.to_ascii_brutal,
                :config => {"Facebook" => item[8], "Twitter" => item[9], "Sina" => item[10]},
                :region_tree_id => region_tree_id)

            #save_info_items
            # build_info_item(item[0], winery)
            #info重新放回wineries.csv里
            new_build_info_item(winery, item[13])
            puts winery.id
          rescue Exception => e
            puts e
          end

        end
      end
    end


  end
  

  #处理多个中文名
  def change_name_zh_to_arr(name)
    name.to_s.split('/').reverse 
  end

  def first_name_zh(name_zh_arr)
    name_zh_arr.pop #取出reverse后的最后一个name
  end

  def other_name_zh(name_zh_arr)
    name_zh_arr.blank? ? nil : name_zh_arr.reverse.join('/') #将顺序调整为原始数据顺序
  end

  #处理酒的品种和百分比
  def get_variety_percentage(variety)
    return [nil, nil] if variety.blank?
    #将variety 格式化为类似于[‘Cf', '10', "DE", '', 'MER'. '12']
    variety_arr = to_ascii(variety).to_s.gsub("\v", "\n").split("\n")
    new_variety_arr = variety_arr.collect{|v| v.split "/"}
    #没有百分比的将百分比设置为空
    new_variety_arr.collect{|v| v.push("") if v.size.odd? }
    final_variety_arr = new_variety_arr.flatten

    variety_percentage = []
    variety_name = []
    Hash[*final_variety_arr].each do |key, value|
      variety_name.push key.strip
      variety_percentage.push value.strip
    end
    #将简写转化为原始数据
    variety_name = short_variety_to_long(variety_name)
    return [variety_name, variety_percentage]
  end

  #将简写的variety转换为原始数据
  def short_variety_to_long variety_name
    file_path = Rails.root.join('lib', 'tasks', 'data', 'region_tree','variety_short.csv')
    csv  = CSV.read(file_path)
    variety_arr = []
    csv.each do |item|
      variety_arr.push item[0], item[1]
    end
    variety_hash = Hash[*variety_arr]
    final_variety = variety_name.collect{|name| name = variety_hash[name] ? variety_hash[name] : name}
    return final_variety
  end
  #适饮年限
  def get_drinkable_time(date)
    return [nil, nil] if date.blank?
    if date.include?('+')  #只有起始年代
      drinkable_begin = date.gsub(/\+/, '')
      drinkable_end = nil
    else
      date_arr = date.split("-")
      drinkable_begin = date_arr.size.odd? ? nil : date_arr.first #处理没有起始年代的情况
      drinkable_end = date_arr.last
    end
    return [drinkable_begin, drinkable_end]
  end


  def to_ascii(string)
    string.to_s.force_encoding('utf-8').to_ascii_brutal
  end

  def to_utf8(string)
    string.to_s.force_encoding('utf-8')
  end

  def build_info_item(winery_number, winery)
    file_directory = Rails.root.join("lib", "tasks", "data", "winery", "info_items")
    info_item_file = Dir.glob("#{file_directory}/#{winery_number}_*.txt")[0]
    if info_item_file
      #读出文件内容
      info_text = File.open(info_item_file)
      #将内容转化为hash
      info_arr = info_text.read.split('#').collect{|i| i.to_ascii_brutal}
      info_arr.delete("") #delete ""
      info_hash = Hash[*info_arr]

      info_hash.each do |key, value|
        winery.info_items.where("title = ?", key).first_or_create!(:title => key, :description => value)
      end
      info_text.close
    end
  end

  def new_build_info_item(winery, info)
    info_arr = info.split('#').collect{|i| i.to_ascii_brutal}
    info_arr.delete_at(0) #删掉第一个元素
    info_hash = Hash[*info_arr]
    info_hash.each do |key, value|
      winery.info_items.where("title = ?", key).first_or_create!(:title => key, :description => value)
    end
  end

  def build_special_comment(register, special_hash)
    special_hash.each do |name, score|
      next if score.blank?
      register.special_comments.
          where("name = ? and score = ?", name, score).
          first_or_create!(:name => name,
                           :score => score)
    end

  end
end
