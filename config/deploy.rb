# set :stages, %w(staging production bob)
# set :stages_dir, 'config/deploy'
# set :default_stage, 'staging'

# require 'mina/multistage'
# require 'mina/bundler'
# require 'mina/rails'
require 'mina/git'
# require 'mina/npm'
# require 'mina/rbenv'  # for rbenv support. (http://rbenv.org)
# require 'mina/rvm' # for rvm support. (http://rvm.io)

# Basic settings:
#   domain       - The hostname to SSH to.
#   deploy_to    - Path to deploy into.
#   repository   - Git repo to clone from. (needed by mina/git)
#   branch       - Branch name to deploy. (needed by mina/git)

set :domain, 'bob.bitknow.org'
set :deploy_to, '/var/www/webfrontgears.com'
set :branch, 'master'
set :repository, 'git@github.com:gray-beard/webfront_website.git'
# set :branch, 'master'

# For system-wide RVM install.
# set :rvm_path, '/usr/local/rvm/scripts/rvm'

# Manually create these paths in shared/ (eg: shared/config/database.yml) in your server.
# They will be linked in the 'deploy:link_shared_paths' step.
set :shared_paths, []
# set :shared_paths, ['config/database.yml', 'config/secrets.yml', 'log', 'config/configatron', 'db/js/migrations/config.json', 'uploads']

# Optional settings:
set :user, 'ctaylor' # Username in the server to SSH to.
#   set :port, '30000'     # SSH port number.
set :forward_agent, true # SSH forward_agent.

# set :npm_options, '--production --userconfig /home/webfront/.npmrc'

# This task is the environment that is loaded for most commands, such as
# `mina deploy` or `mina rake`.
task :environment do
  # If you're using rbenv, use this to load the rbenv environment.
  # Be sure to commit your .ruby-version or .rbenv-version to your repository.
  # invoke :'rbenv:load'
  # queue 'source ~/.nvm/nvm.sh; nvm use iojs'

  # For those using RVM, use this to load an RVM version@gemset.
  # invoke :'rvm:use[ruby-2.2.2@default]'
end

# Put any custom mkdir's in here for when `mina setup` is ran.
# For Rails apps, we'll make some of the shared paths that are shared between
# all releases.
task :setup => :environment do
  queue! %[mkdir -p "#{deploy_to}/#{shared_path}"]
  # queue! %[chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/log"]

  # queue! %[mkdir -p "#{deploy_to}/#{shared_path}/config"]
  # queue! %[chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/config"]

  # queue! %[mkdir -p "#{deploy_to}/#{shared_path}/uploads"]
  # queue! %[chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/uploads"]

  # queue! %[touch "#{deploy_to}/#{shared_path}/config/database.yml"]
  # queue! %[touch "#{deploy_to}/#{shared_path}/config/secrets.yml"]

  # queue! %[mkdir -p "#{deploy_to}/#{shared_path}/db/js/migrations"]
  # queue! %[mkdir -p "#{deploy_to}/#{shared_path}/db/js/node_modules"]
  # queue! %[touch "#{deploy_to}/#{shared_path}/db/js/migrations/config.json"]

  # queue %[echo "-----> Be sure to edit '#{deploy_to}/#{shared_path}/config/database.yml' and 'secrets.yml'."]

  queue %[
    repo_host=`echo $repo | sed -e 's/.*@//g' -e 's/:.*//g'` &&
    repo_port=`echo $repo | grep -o ':[0-9]*' | sed -e 's/://g'`
  ]
end

# desc "Force update from seeds"
# task :force_seed => :environment do
#   in_directory "#{deploy_to}/current" do
#     queue! "SEEDS_FORCE_UPDATE=true #{rake} db:seed"
#   end
# end

desc "Deploys the current version to the server."
task :deploy => :environment do
  to :before_hook do
    # Put things to run locally before ssh
  end
  deploy do
    # Put things that will set up an empty directory into a fully set-up
    # instance of your project.
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    # invoke :'bundle:install'
    # invoke :'rails:db_migrate'
    # queue! "#{rake} db:migrate" #force it to run. seems to get false negative on migrations changed check. Specifically, if I changed to a different database it doesn't notice.

    # in_directory './db/js' do
    #   queue! 'source ~/.nvm/nvm.sh; nvm use iojs; npm-cache install'
    #   queue! 'source ~/.nvm/nvm.sh; nvm use iojs; mygrate last || mygrate up'
    # end
    # # queue! "#{rake} db:seed"
    # queue! "#{rake} gears:migrate"

    # # queue! "#{rake} assets:precompile"
    # invoke :'rails:assets_precompile'
    # queue! "#{rake} gears:migrate"
    invoke :'deploy:cleanup'

    to :launch do
      # queue! "#{rake} gears:clear_cache"
      # queue! "mkdir -p #{deploy_to}/#{current_path}/tmp/"
      # queue! "touch #{deploy_to}/#{current_path}/tmp/restart.txt"
    end
  end
end

# For help in making your deploy script, see the Mina documentation:
#
#  - http://nadarei.co/mina
#  - http://nadarei.co/mina/tasks
#  - http://nadarei.co/mina/settings
#  - http://nadarei.co/mina/helpers
