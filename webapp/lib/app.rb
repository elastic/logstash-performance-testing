require 'initialize'
require 'sidekiq'
require 'helpers'
require 'json'
require 'app/charts'
require 'app/config'
require 'app/app_fetch'
require 'workers/test_worker'

class App < Sinatra::Application

  get '/' do
    erb :index
  end

  post '/hooks/pull' do
    body = JSON.parse(request.body.read)
    Microsite::TestWorker.perform_async('pull_hook', body)
  end

end
