#encoding: UTF-8
namespace :admin do

  desc "创建新的admin用户。"
  task :build_new_admin  => :environment do
    #删除旧的用户
    old_admin_user = AdminUser.where(email:'admin@example.com').first
    old_admin_user.destroy if old_admin_user
    #创建新用户
    new_admin_usr = AdminUser.new(email:'info@sidways.com', password:'Sidways123#@!')
    new_admin_usr.save
  end
end