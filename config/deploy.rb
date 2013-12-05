require "bundler/capistrano"
require "capistrano-rbenv"

load "deploy/assets"

default_run_options[:pty] = true

role :web, 'kant.sugarpond.net'
role :app, 'kant.sugarpond.net'
role :db, 'kant.sugarpond.net', primary: true
#chef_role [:web, :app], 'roles:app_server AND chef_environment:production'
set :user, 'deploy'

#role :web, 'localhost'
#set :user, 'www-data'
#set :ssh_options, {port: 2222, keys: ['~/.ssh/id_dsa']}

set :rbenv_path, "/opt/rbenv"
set :rbenv_setup_shell, false
set :rbenv_setup_default_environment, false
set :rbenv_setup_global_version, false
set :rbenv_ruby_version, "1.9.3-p484"

set :application, "sugarpond_errbit"
set :repository, "git://github.com/nbudin/errbit"
set :deploy_to, "/var/www/#{application}"
set :use_sudo, false

set :scm, :git
set :bundle_without, [:development, :test]

namespace(:deploy) do
  desc "Link in config files needed for environment"
  task :symlink_config, :roles => :app do
    %w(config.yml initializers/secret_token.rb initializers/devise.rb mongoid.yml).each do |config_file|
      run <<-CMD
        ln -nfs #{shared_path}/config/#{config_file} #{release_path}/config/#{config_file}
      CMD
    end
  end
  
  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end
end

before "deploy:finalize_update", "deploy:symlink_config"
after "deploy", "deploy:cleanup"
