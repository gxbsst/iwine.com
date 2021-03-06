class CreateNotes < ActiveRecord::Migration
  def change
    create_table :notes do |t|
      t.string      :uuid, :limit => 36
      t.belongs_to  :user
      t.belongs_to  :wine_detail
      # t.belongs_to  :wine_region_tree
      t.integer     :region_tree_id
      t.belongs_to  :wine_style
      t.string      :photo
      t.integer     :vintage
      t.string      :name
      t.string      :other_name
      t.integer     :rating  #评分
      t.string      :location
      t.text        :grape   # 葡萄类型及百分比 葡萄种类id:10.0;  葡萄种类id:20.0;
      t.string      :alcohol # 酒精度  格式： 12.5
      t.float       :price   # 价格
      t.text        :comment # 简评
      # 外观
      t.integer     :appearance_clarity, :default => 0 # 澄清度 1-1
      t.integer     :appearance_intensity, :default => 0  # 强度 0 - 5
      t.text        :appearance_color      # 颜色 , 对照jamse表
      t.text        :appearance_other      # 其他信息
      # 香气
      t.integer     :nose_condition, :default => 0      # 香气状况
      t.integer     :nose_intensity, :default => 0      # 强度
      t.integer     :nose_development, :default => 0    # 发展
      t.text        :nose_aroma           # 特征
      # 口感
      t.integer     :palate_sweetness, :default => 0      # 甜度
      t.integer     :palate_acidity, :default => 0        # 酸度
      t.integer     :palate_alcohol, :default => 0              # 酒精度
      t.integer     :palate_tannin_level, :default => 0         # 单宁程度
      t.integer     :palate_tannin_nature, :default => 0        # 单宁性质
      t.integer     :palate_body, :default => 0                 # 酒体
      t.integer     :palate_flavor_intensity, :default => 0     # 风味浓郁度
      t.text        :palate_flavor               # 风味特征
      t.integer     :palate_length               # 余味
      t.text        :palate_other               # 其他
      #总结
      t.integer  :conclusion_quality, :default => 0          #质量
      t.text     :conclusion_reason           #理由
      t.integer  :drinkable_begin_at          # 试饮年限开始
      t.integer  :drinkable_end_at            # 试饮年限结束
      t.text     :conclusion_other            # 其他

      t.integer  :delete_flag              # 删除标志
      t.integer  :sync_flag                # 同步标志
      t.datetime :serverTime               # 服务器时间
      t.integer  :status_flag              # 状态标志
      t.string   :la                       # 经度
      t.string   :lo                       # 纬度
      t.integer  :photoSize                # 图片大小

      t.string   :user_agent   # 使用什么上传品酒辞 "iwine.com" "iwine_notes·"

      t.timestamps
    end
    #add_index :notes, :id, :unique => true
  end
end
