require 'initialize'
require 'sidekiq'
require 'json'
require 'app/config'
require 'app/fetcher'
require 'workers/test_worker'

class App < Sinatra::Application

  #get the events stored for a given period of time
  get "/data/events.json" do
    data = Microsite::Fetcher.fetch("events")
    respond_with(data)
  end

  # gets you the startup time for a given period of time
  get "/data/startup_time.json" do
    data = Microsite::Fetcher.fetch("start_time")
    respond_with(data)
  end

  # hook that lets you run the api process
  post "/hook/pull" do
    body = JSON.parse(request.body.read)
    Microsite::TestWorker.perform_async('pull_hook', body)
  end

  private

  def respond_with(data={})
    halt 404 if data.empty?
    data.to_json
  end
end
