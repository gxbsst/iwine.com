# encoding: utf-8
namespace :trait do


  desc "初始化表信息"
  task :init => :environment do
    PARENTS = {
        'Floral' => { :zh => '花香', :en => 'Floral'},
        'GreenFruit' => { :zh => '绿色水果', :en => 'Green Fruit'},
        'CitrusFruit' => { :zh => '柑橘类水果', :en => 'Citrus Fruit'},
        'StoneFruit' => { :zh => '带核水果', :en => 'Stone Fruit'},
        'TropicalFruit' => { :zh => '热带水果', :en => 'Tropical Fruit'},
        'RedFruit' => { :zh => '红色水果', :en => 'Red Fruit'},
        'BlackFruit' => { :zh => '黑色水果', :en => 'Black Fruit'},
        'DriedFruit' => { :zh => '干果', :en => 'Dried Fruit'},
        'Unripe' => { :zh => '未成熟的', :en => 'Unripe'},
        'Herbaceous' => { :zh => '青草类', :en => 'Herbaceous'},
        'Herbal' => { :zh => '草药类', :en => 'Herbal'},
        'Vegetable' => { :zh => '蔬菜', :en => 'Vegetable'},
        'SweetSpice' => { :zh => '甜香料', :en => 'Sweet Spice'},
        'PungentSpice' => { :zh => '强烈的香料', :en => 'Pungent Spice'},
        'Autolytic' => { :zh => '酵母自溶解', :en => 'Autolytic'},
        'DairyMLF' => { :zh => '乳制品/乳酸发酵', :en => 'Dairy/MLF'},
        'Oak' => { :zh => '木桶系', :en => 'Oak'},
        'Kernel' => { :zh => '坚果', :en => 'Kernel'},
        'Animal' => { :zh => '动物', :en => 'Animal'},
        'Maturity' => { :zh => '熟成', :en => 'Maturity'},
        'Mineral' => { :zh => '矿物', :en => 'Mineral'}
    }
    TRAIT = YAML.load_file(Rails.root.join('lib', 'tasks', 'data', 'trait.yml'))
    NOTE_TRAIT_ZH = TRAIT['zh']
    NOTE_TRAIT_EN = TRAIT['en']


    # init parent
    NOTE_TRAIT_ZH.keys.each do |parent|
      ::WineTrait.where(:key => parent).first_or_create(:parent_id => 0,
                                                        :name_zh => PARENTS[parent][:zh],
                                                        :name_en => PARENTS[parent][:en],
                                                        :key => parent)
    end
    # init zh
    NOTE_TRAIT_ZH.each do |k, v|
      parent_id = ::WineTrait.where(:key => k).first.id
      v.each do |key, value|
        ::WineTrait.where(:key => key).first_or_create(:parent_id => parent_id, key => key, :name_zh => value)
      end
    end

    NOTE_TRAIT_EN.each do |k, v|
      parent_id = ::WineTrait.where(:key => k).first.id
      v.each do |key, value|
        ::WineTrait.where(:key => key).first.update_attributes!(:name_en => value)
      end
    end
  end

end
