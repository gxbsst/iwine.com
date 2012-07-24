# encoding: utf-8
FactoryGirl.define do
  factory :profile, :class => 'Users::Profile' do
    user { |c| c.association(:user) }
    nickname "Weston"
    bio "Here is My Bio"
    #living_city "Shanghai"
    hometown "Guangxi Baise"
    gender "1"
    birthday Time.new(1981, 6, 15)
    vocation 2
    company "Sidways"
    real_name "韦旭红"
    school "Baise Un"
    phone_number "18621699591"
    qq "56531999"
  end

  trait :configed do
    _config <<-HTML
        --- !omap
        - :share: !omap
          - :wine_cellar: '1'
          - :wine_detail_comment: '1'
          - :wine_simple_comment: '1'
        - :notice: !omap
          - :comment: '1'
          - :message: '1'
          - :email:
            - '1'
            - '2'
            - '3'
            - '4'
            - '5'
        HTML
  end

  trait :unconfiged do
    _config nil
  end

end
