# encoding: utf-8
module Notes
  class NoteItem
    extend ActiveModel::Naming
    #include ActiveModel
    #include ActiveModel::Serialization
    #
    #has_many :comments

    attr_accessor :appearance, :nose, :palate, :conclusion, :photo, :wine, :location, :note, :id
    NOTE_TRAIT_ZH = NOTE_TRAIT['zh']
    def initialize(note)
      self.id = note['id']
      self.photo      = Photo.new(note['cover'])
      self.wine       = Wine.new(note['wine'])
      self.appearance = Appearance.new(note['appearance'])
      self.nose       = Nose.new(note['nose'])
      self.palate     = Palate.new(note['palate'])
      self.conclusion = Conclusion.new(note['conclusion'])
      self.location   = Location.new(note['location'])
      self.note = Note.new(note)

    end

    def self.find(id)
      result = {}
      result['id']  = id
      Note.new(result)
    end

    #def comments
    #  ::Comment.where(:commentable_type => 'Note', :commentable_id => 1)
    #end

    class Note < Struct.new(:serverTime, :id, :rating, :modifiedDate, :statusFlag, :agent)

      AGENT = {'NOTES_AGENT' => 'iWineNote', 'IWINE_AGENT' => 'iWine'}

      def initialize(result)
        @serverTime = result['serverTime']
        self.id = result['id']
        @rating = result['rating']
        self.modifiedDate = result['modifiedDate']
        self.statusFlag = result['statusFlag']
        @agent =  result['agent']
      end

      def created_at=(servertime)
        @serverTime = serverTime
      end

      def created_at
        Date.parse(@serverTime)
      end

      def to_param  # overridden
        self.id
      end

      def rating=(rating)
        @rating = rating
      end

      def rating
        @rating + 1
      end

      def agent
        AGENT[@agent]
      end

    end

    # 外观
    class Appearance < Struct.new(:clarity, :intensity, :color, :other)

      APPEARANCE = NOTE_DATA['note']['appearance']

      def initialize(result)
        clarity = Notes::HelperMethods.polishing(result['clarity'], 2)
        @clarity_a = clarity[0].to_i
        @clarity_b =clarity[1].to_i
        @intensity = result['intensity']
        self.color = result['color']
        # 如果yml文件没有值，请另外设定值
        self.other = result['other']
      end

      def text
        #澄清度 不变
        #强度：{中等} 的 {颜色}
        # 其他
        h = {}
        instance_variables.each{|a|
          s = a.to_s
          n = s[1..s.size]
          v = instance_variable_get a
          h[n] = v
        }
        new_array = []
        h.each do |k,v|
          join_text = if k == 'intensity'
                        "#{APPEARANCE[k][v.to_i]}的#{self.color_text}"  unless APPEARANCE[k][v.to_i].blank?
                      else
                        APPEARANCE[k][v.to_i]
                      end
          new_array <<  join_text
        end
        new_array << "#{self.other}" if self.other.present?
        new_array.compact.delete_if{|i|i.blank?}.join("、")
      end

      def color_image_name
        return '' if self.color.blank?
        new_array = self.color.gsub(" ", "_").split('_').values_at(3,6,7)
        new_array[1] + '-' + new_array[2] + '-' + APPEARANCE['color_num'][new_array[0]].to_s
      end

      def color_text
        return '' if self.color.blank?
        new_array = self.color.gsub(" ", "_").split('_').values_at(3,6,7)
        "#{APPEARANCE['color'][new_array[0]]}  #{APPEARANCE['color_name'][new_array[2]]}"
      end

    end

    # 香气
    class Nose < Struct.new(:condition, :intensity, :development, :aroma, :other)

      NOSE = NOTE_DATA['note']['nose']

      def initialize(result)
        @condition = result['condition']
        @intensity = result['intensity']
        @development = result['development']
        # 如果yml文件没有值，请另外设定值
        self.aroma = result['aroma']
        self.other = result['other']
      end

      def text
        # 状况 不变
        # 强度 {} 的香气
        # 发展 不变
        # 特征 ｛｝ 的味道
        h = {}
        instance_variables.each{|a|
          s = a.to_s
          n = s[1..s.size]
          v = instance_variable_get a
          h[n] = v
        }
        new_array = []
        h.each do |k,v|
          join_text = if k == 'intensity'
                        "#{NOSE[k][v.to_i]}的香气" unless NOSE[k][v.to_i].blank?
                      else
                        NOSE[k][v.to_i]
                      end
          new_array <<  join_text
        end
        # 风味特征
        new_array << "有#{self.aroma_text}的味道" if self.aroma_text.present?
        new_array.compact.delete_if{|i|i.blank?}.join("，")
      end

      def aroma_text
        return '' if aroma.blank?
        new_array = []
        aroma.split(';').compact.each do |i|
         new_array << NOTE_TRAIT['zh'][i]
        end
        new_array.join('、')
      end

    end

    # 口感
    class Palate < Struct.new(:sweetness, :acidity, :alcohol, :tanninLevel, :tanninNature, :body, :flavorIntensity, :flavor, :length, :other)

      PALATE = NOTE_DATA['note']['palate']

      def initialize(result)
        @sweetness = result['sweetness']
        @acidity = result['acidity']
        @alcohol = result['alcohol']
        @body = result['body']
        @tanninLevel = result['tanninLevel']
        self.flavorIntensity = result['flavorIntensity']

        tannin = Notes::HelperMethods.polishing(result['tanninNature'], 3)
        @tannin_nature_a = tannin[0].to_i
        @tannin_nature_b = tannin[1].to_i
        @tannin_nature_c = tannin[2].to_i
        # 如果yml文件没有值，请另外设定值
        self.flavor = result['flavor']
        self.other = result['other']
        self.length = result['length']
      end

      def text
        #  甜度 除｛中等甜度） 其他不变
        #  酸度 {}的酸度
        # 单宁: 先性质，程度的单宁
        # 酒精度: {} 的酒精度
        # 酒体:  {} 的酒体
        # 风味浓郁度： ｛｝的 {风味特征}
        # 其他细节
        # 余味: 余味中等

        h = {}
        instance_variables.each{|a|
          s = a.to_s
          n = s[1..s.size]
          v = instance_variable_get a
          h[n] = v
        }
        new_array = []
        h.each do |k,v|
          join_text = if k == 'sweetness'
                        PALATE[k][v.to_i] == '中等' ? "中等甜度" : PALATE[k][v.to_i]
                      elsif k == 'acidity'
                        "#{PALATE[k][v.to_i]}的酸度" unless PALATE[k][v.to_i].blank?
                      elsif k == 'tanninLevel' || k == 'tannin_nature_a' || k == 'tannin_nature_b' || k == 'tannin_nature_c'
                        # do nothing
                      elsif k == 'alcohol'
                        "#{PALATE[k][v.to_i]}的酒精度"  unless PALATE[k][v.to_i].blank?
                      elsif k == 'body'
                        "#{PALATE[k][v.to_i]}的酒体"   unless PALATE[k][v.to_i].blank?
                      else
                        PALATE[k][v.to_i]
                      end
          new_array <<  join_text
        end
        # 单宁
        (new_array << "#{self.tannin_text}、#{PALATE['tanninLevel'][@tanninLevel.to_i]} 的单宁") unless self.tannin_text.blank?
        # 风味浓郁度
        new_array << "有#{flavorIntensity_text}#{self.flavor_text}的味道" unless self.flavor_text.blank?
        # 余味
        (new_array << "余味#{ PALATE['length'][self.length]}") if self.length.to_i > 0
        # 其他
        new_array << self.other unless self.other.blank?
        new_array.compact.delete_if{|i|i.blank?}.join("， ")
      end

      def tannin_text
        [PALATE['tannin_nature_a'][@tannin_nature_a],
         PALATE['tannin_nature_b'][@tannin_nature_b],
         PALATE['tannin_nature_c'][@tannin_nature_c]
         ].compact.delete_if{|i|i.blank?}.join('、')
      end

      def flavorIntensity_text
        if self.flavorIntensity.to_i != 0
          "#{PALATE['flavorIntensity'][self.flavorIntensity]}的"
        end
      end

      def flavor_text
        return '' if flavor.blank?
        new_array = []
        flavor.split(';').compact.each do |i|
          new_array << NOTE_TRAIT['zh'][i]
        end
        new_array.join('、')
      end

    end

    # 结论
    class Conclusion < Struct.new(:quality, :reason, :drinkwindow, :other)

      CONCLUSION = NOTE_DATA['note']['conclusion']

      def initialize(result)
        @quality = result['quality']

        self.reason = result['reason']
        self.drinkwindow = result['drinkwindow']
        self.other = result['other']
      end

      def text
        # 质量 质量｛｝
        # 理由： 因为｛理由｝
        # 适饮期限为：～～～
        #
        h = {}
        instance_variables.each{|a|
          s = a.to_s
          n = s[1..s.size]
          v = instance_variable_get a
          h[n] = v
        }


        new_array = []
        h.each do |k,v|
          join_text = if k == 'quality'
                        "质量#{CONCLUSION[k][v.to_i]}" unless CONCLUSION[k][v.to_i].blank?
                      else
                        CONCLUSION[k][v.to_i]
                      end
          new_array <<  join_text
        end
        # 理由
        new_array << "因为#{self.reason}" unless self.reason.blank?
        # 其他
        new_array << "#{self.other}" unless self.other.blank?
        new_array.compact.delete_if{|i|i.blank?}.join("，")
      end
    end

    # 图片
    class Photo < Struct.new(:image, :size)

      # TODO: move to ...
      DEFAULT_CONFIG = {
          :pre => 'http://',
          :host => '192.168.11.29:8082',
          :base_url => 'iwinenotes/images',
 
          :version => 'noraml',
          #:host => NOTE_DATA['note']['photo_location']['host'],
          #:base_url => NOTE_DATA['note']['photo_location']['base_url'],
          #:version => NOTE_DATA['note']['photo_location']['version'],
          :id => '',
          :pattern => ''
      }


      def initialize(result)
        self.image = result['image']
        self.size = result['size']
      end

      def images(options = {})
        if self.image.blank?
          false
        else
          version =  (options.has_key? :version) ? options[:version] : 'normal'
          self.image.split(',').map{|file| self.generate_url(:id => file, :version => version, :pattern => options[:pattern])}
        end

      end

      def generate_url(options)
        options =  DEFAULT_CONFIG.merge(options)
        url =  options.values.join("/")
      end

      #def url(options)
      #  if self.image.blank?
      #    'Not Image'
      #  else
      #    options[:id] = self.image
      #    options =  DEFAULT_CONFIG.merge(options)
      #    url =  options.values.join("/")
      #  end
      #end

    end

    # wine
    class Wine < Struct.new(:detail, :sName, :oName, :vintage, :rating, :region, :style, :alcohol, :price, :comment, :varienty)

      def initialize(r)
        self.detail = r['detail']
        self.sName = r['sName']
        self.oName =  r['oName']
        self.vintage = r['vintage']
        @rating = r['rating']
        self.region = r['region']
        self.style = r['style']
        self.alcohol = r['alcohol']
        self.price = r['price']
        self.comment = r['comment']
        self.varienty = r['varienty']
      end

      def rating=(rating)
        @rating = rating
      end

      def rating
        @rating + 1
      end

      def name_zh
        #(vintage || '').to_s <<  (oName || sName)
         if self.oName.blank?
           cname = sName
         else
           cname = oName
         end
        "#{(vintage || '')} #{cname}"
      end

      def name_en
        "#{(vintage || '')} #{sName}"
      end

      def region_zh(options = {})
        region_trees = get_region_path
        return nil if region_trees.blank?
        options[:connector] = ">" unless options.has_key? :connector
        region_trees.collect{|r| r.name_zh }.join(options[:connector] )
      end

      def region_en(options = {})
        region_trees = get_region_path
        return nil if region_trees.blank?
        options[:connector] = ">" unless options.has_key? :connector
        region_trees.collect{|r| r.origin_name }.join(options[:connector] )
      end

      def get_region_path
        return nil if region.blank? || ::Wines::RegionTree.where("id = #{self.region}").blank?
        region = ::Wines::RegionTree.find(self.region)
        parent = region.parent
        path = [region]
        until parent == nil
          path << parent
          parent = parent.parent
        end
        path.reverse!
      end

    end 
    # 地址
    class Location < Struct.new(:location, :la, :lo)

      def initialize(r)
        if r
          self.location = r['location']
          self.la = r['la']
          self.lo = r['lo']
        end
      end

    end  
  end
end