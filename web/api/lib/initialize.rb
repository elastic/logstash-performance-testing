require 'app/config'

env = (ENV['RACK_ENV'] || :development).to_sym

ROOT = File.expand_path("..", File.dirname(__FILE__))

set :root, ROOT
set :environment, env
set :public_folder, "#{ROOT}/public"
set :protection, except: :path_traversal


set :app_config, Microsite::Config.load

Dir[ File.expand_path('workers/*.rb', __FILE__) ].each   { |file| require file }
