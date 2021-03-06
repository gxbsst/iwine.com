set_default(:unicorn_user) { user }
set_default(:unicorn_pid) { "#{current_path}/tmp/pids/unicorn.pid" }
set_default(:unicorn_config) { "#{shared_path}/config/unicorn.rb" }
set_default(:unicorn_log) { "#{shared_path}/log/unicorn.log" }
set_default(:unicorn_workers, 8)

namespace :unicorn do
  desc "Setup Unicorn initializer and app configuration"
  task :setup, roles: :app do
    #run "mkdir -p #{shared_path}/config"
    template "unicorn.rb.erb", unicorn_config
    #run "ln -nfs #{shared_path}/config/unicorn.rb #{release_path}/config/unicorn.rb"
    #template "unicorn_init.erb", "/tmp/unicorn_init"
    #run "chmod +x /tmp/unicorn_init"
    #run "#{sudo} mv /tmp/unicorn_init /etc/init.d/unicorn_#{application}"
    #run "#{sudo} update-rc.d -f unicorn_#{application} defaults"
    #sudo "ln -nfs #{current_path}/config/unicorn_init.sh /etc/init.d/unicorn_#{application}"
  end
  after "deploy:setup_config", "unicorn:setup"

  desc "symlink unicorn  configuration"
  task :symlink_file, roles: :app do
    run "ln -nfs #{shared_path}/config/unicorn.rb #{current_path}/config/unicorn.rb"
  end

  after "deploy:symlink_config", "unicorn:symlink_file"

  %w[start stop restart].each do |command|
    desc "#{command} unicorn"
    task command, roles: :app do
      run "lib unicorn_#{application} #{command}"
    end
    after "deploy:#{command}", "unicorn:#{command}"
  end
end
