# encoding: utf-8
require "bundler/capistrano"
load "config/recipes/base"
#load "config/recipes/nginx"
load "config/recipes/unicorn"
#load "config/recipes/postgresql"
#load "config/recipes/mysql"
#load "config/recipes/nodejs"
#load "config/recipes/rbenv"
load "config/recipes/check"
load "config/recipes/monit"

server "dev.iwine.com", :web, :app, :db, primary: true

set :default_environment, {
  'LANG' => 'en_US.UTF-8'
}

set :application, "iWine"
set :user, "iwine"
set :deploy_via, :remote_cache
set :use_sudo, false

set :scm, "git"
set :repository, "ssh://git@www.sidways.com:20248/patrick_ruby"

if ENV['RAILS_ENV'] =='production'
  set :branch, "master"
  set :deploy_to, "/srv/rails/production.iwine.com"
else
  set :branch, "develop"
  set :deploy_to, "/srv/rails/development.iwine.com"
end

#set :branch, "master"
#set :deploy_to, "/srv/rails/production.iwine.com"
#set :branch, "develop"
#set :deploy_to, "/srv/rails/iwine.com"


default_run_options[:pty] = true
ssh_options[:forward_agent] = true

after "deploy", "deploy:cleanup" # keep only the last 5 releases

namespace :deploy do
  # unicorn
  #%w[start stop restart].each do |command|
    #desc "#{command} unicorn server"
    #task command, roles: :app, except: {no_release: true} do
      #run "/etc/init.d/unicorn_#{application} #{command}"
    #end
  #end

  task :restart, roles: :app do
    #run "sudo kill -9 `cat #{deploy_to}/current/tmp/pids/unicorn.pid`"
    #run "cd #{deploy_to}/current/ && bundle exec unicorn_rails -c ./config/unicorn.rb -D  -E production"
    run "/etc/init.d/unicorn_#{application} restart"
    #  run "touch #{current_path}/tmp/restart.txt" # passenger
    #sudo "/home/iwine/unicorn_restart.sh" # unicorn
  end

  task :setup_config, roles: :app do
    #sudo "ln -nfs #{current_path}/config/nginx.conf /etc/nginx/sites-enabled/#{application}"
    #sudo "ln -nfs #{current_path}/config/unicorn_init.sh /etc/init.d/unicorn_#{application}"
    run "mkdir -p #{shared_path}/config"
    run "mkdir -p #{shared_path}/config/oauth"
    # database config
    put File.read("config/database.example.yml"), "#{shared_path}/config/database.yml"
    # oauth config
    put File.read("config/oauth/development_all.example.yml"), "#{shared_path}/config/oauth/development_all.yml"
    put File.read("config/oauth/production_all.example.yml"), "#{shared_path}/config/oauth/production_all.yml"
    put File.read("config/oauth/douban.example.yml"), "#{shared_path}/config/oauth/douban.yml"
    put File.read("config/oauth/qq.example.yml"), "#{shared_path}/config/oauth/qq.yml"
    put File.read("config/oauth/sina.example.yml"), "#{shared_path}/config/oauth/sina.yml"

    # photos
    run "mkdir -p #{shared_path}/uploads"
    puts "Now edit the config files in #{shared_path}."
  end
  after "deploy:setup", "deploy:setup_config"

  task :symlink_config, roles: :app do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{shared_path}/config/oauth/development_all.yml #{release_path}/config/oauth/development_all.yml"
    run "ln -nfs #{shared_path}/config/oauth/production_all.yml #{release_path}/config/oauth/production_all.yml"
    run "ln -nfs #{shared_path}/config/oauth/douban.yml #{release_path}/config/oauth/douban.yml"
    run "ln -nfs #{shared_path}/config/oauth/qq.yml #{release_path}/config/oauth/qq.yml"
    run "ln -nfs #{shared_path}/config/oauth/sina.yml #{release_path}/config/oauth/sina.yml"
    run "ln -nfs #{shared_path}/config/unicorn.rb #{release_path}/config/unicorn.rb"
  end
  after "deploy:finalize_update", "deploy:symlink_config"


  desc "Update the crontab file"
  task :update_crontab, :roles => :db do
    run "cd #{deploy_to}/current && whenever --update-crontab #{application}"
  end
  after 'deploy', "deploy:create_database", 'deploy:migrate'
  after "deploy:update", "deploy:update_crontab"

  desc "create database "
  task "create_database", :roles => :web do
    run("cd #{deploy_to}/current && /usr/bin/env rake db:create RAILS_ENV=production")
    puts "Pls INIT WINE DATA / PHOTO, AND EXCUTE cap deploy:init_data"
  end

  desc "init all seed data"
  task "init_data", :roles => :web do
    run("cd #{deploy_to}/current && /usr/bin/env rake app:init_whole_data RAILS_ENV=production")
  end

  desc "init wine photos"
  task "init_photo", :roles => :web do
    run("cd #{deploy_to}/current && /usr/bin/env rake photo:upload_all_photo RAILS_ENV=production")
  end
  after 'deploy:init_data', 'deploy:init_photo', 'deploy:search_build', 'deploy:assets_precompile', 'delayed_job:restart', "deploy:update_crontab"

  desc "search build index"
  task "search_build", :roles => :web do
    run("cd #{deploy_to}/current && /usr/bin/env rake search:build RAILS_ENV=production")
  end

  desc "rake assets:precompile"
  task "assets_precompile", :roles => :web do
    run("cd #{deploy_to}/current && /usr/bin/env rake assets:precompile RAILS_ENV=production")
  end

  desc "symlink_upload"
  task :symlink_upload, :roles => :web do
    run "ln -nfs #{shared_path}/uploads #{release_path}/public/uploads"
  end
  after "deploy:update_code", "deploy:symlink_upload"

  desc "Make sure local git is in sync with remote."
  task :check_revision, roles: :web do
    unless `git rev-parse HEAD` == `git rev-parse origin/master`
      puts "WARNING: HEAD is not the same as origin/master"
      puts "Run `git push` to sync changes."
      exit
    end
  end

  #before "deploy", "deploy:check_revision"
end

namespace :delayed_job do 
  desc "Restart the delayed_job process"
  task :restart, :roles => :app do
    run "cd #{current_path}; RAILS_ENV=#{rails_env} script/delayed_job restart"
  end
end

after "deploy:update", "delayed_job:restart"


