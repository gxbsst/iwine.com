# encoding: utf-8
namespace :wine_color do
    desc "初始化表信息"
    task :init => :environment do
      NOTE_COLOR_LEVEL = NOTE_COLOR['level']
      NOTE_COLOR_NAME = NOTE_COLOR['name']

      PARENTS = {
          'White' => { :zh => '白葡萄酒', :en => 'White'},
          'Red' => { :zh => '红葡萄酒', :en => 'Red'},
          'Rose' => { :zh => '桃红葡萄酒', :en => 'Rose'}
      }
      # init parent
      PARENTS.keys.each do |parent|
        ::WineColor.where(:key => parent).first_or_create(:parent_id => 0,
                                                          :name_zh => PARENTS[parent][:zh],
                                                          :name_en => PARENTS[parent][:en],
                                                          :key => parent)
      end

      # init child
      NOTE_COLOR_LEVEL.each do |k, v|
        NOTE_COLOR_NAME.each do |k2, v2|
          parent_id = ::WineColor.where(:key => k2).first.id
          v2.each do |k3, v3|
            key = "ATN_Color_Pre_#{k} ATN_Color_#{k2}_#{k3}"
            name_en = "#{k} #{k3}"
            name_zh = "#{v['text']} #{v3}"
            k_e = if k3 == 'Lemon-green'
                    'LemonGreen'
                  elsif k3 == 'Onion-skin'
                   'Onion'
                  else
                    k3
                  end
            image = "#{k2}-#{k_e}-#{v['num']}.png"

            ::WineColor.where(:key => key).first_or_create(:parent_id => parent_id,
                                                          key => key,
                                                          :name_zh => name_zh,
                                                          :name_en => name_en,
                                                          :image => image )
          end
        end
      end

    end

  end
