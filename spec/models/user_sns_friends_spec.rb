require 'spec_helper'

describe UserSnsFriend do

  describe 'SnsProviders::QqWeibo' do

    it "should sync qq friends" do
      SnsProviders::QqWeibo.sync
      SnsProviders::QqWeibo.all.count.should > 0
    end

  end

  describe 'SnsProviders::Sina' do

    it "should sync sina weibo friends" do
      SnsProviders::SinaWeibo.sync
      SnsProviders::SinaWeibo.all.count.should > 1
    end

  end

end
