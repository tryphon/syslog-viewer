set :application, "log-access"
set :repository,  "git://projects.tryphon.priv/log-access"

server "sandbox", :app, :web, :db, :primary => true
#server "monitor.tryphon.priv", :app, :web, :db, :primary => true

set :deploy_to, "/var/www/log-access"

set :keep_releases, 5
after "deploy:update", "deploy:cleanup"
after "deploy:finalize_update", "deploy:symlink_config_shared"

require "bundler/capistrano"

namespace :deploy do
  task :setup, :except => { :no_release => true } do
    dirs = [deploy_to, releases_path, shared_path]
    dirs += shared_children.map { |d| File.join(shared_path, d.split('/').last) }
    run "#{try_sudo} mkdir -p #{dirs.join(' ')}"
    run "sudo chmod g+w #{dirs.join(' ')}" if fetch(:group_writable, true)
  end

  desc "Symlinks for files managed by puppet"
  task :symlink_config_shared, :except => { :no_release => true }  do
    run "ln -nfs #{shared_path}/config/config.rb #{release_path}/config/"
  end

  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end
