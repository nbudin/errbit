require "bundler/vlad"

set :application, "sugarpond-errbit"
set :user, "www-data"
set :domain, "#{user}@popper.sugarpond.net"
set :repository, "git://github.com/nbudin/errbit"
set :deploy_to, "/var/www/#{application}"
set :rvm_cmd, nil #"source /etc/profile.d/rvm.sh"
set :bundle_cmd, [ rvm_cmd, "env $(cat #{shared_path}/config/production.env) bundle" ].compact.join(" && ")
set :rake_cmd, "#{bundle_cmd} exec rake"

namespace :vlad do
  remote_task :copy_config_files, :roles => :app do
    run "cp #{shared_path}/config/* #{current_path}/config/"
  end

  namespace :assets do
    remote_task :precompile, :roles => :app do
      run "cd #{release_path} && #{rake_cmd} assets:precompile"
    end
  end
end

task "vlad:deploy" => %w[
  vlad:update vlad:bundle:install vlad:copy_config_files vlad:migrate vlad:assets:precompile vlad:cleanup vlad:start_app
]
