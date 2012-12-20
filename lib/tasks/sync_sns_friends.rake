namespace :sync_sns_friends do

  desc "Sync All Firiends"
  task :sync_all => :environment do
    UserSnsFriend.sync
  end

  desc "Sync Sina WEibo"
  task :sync_sina => :environment do
    SnsProviders::SinaWeibo.sync
  end

  desc "TODO"
  task :sync_qq => :environment do
    SnsProviders::QqWeibo.sync
  end

  desc "TODO"
  task :sync_tqq2 => :environment do
    SnsProviders::Tqq2.sync
  end

  desc "TODO"
  task :sync_douban => :environment do
    SnsProviders::Douban.sync
  end

end
