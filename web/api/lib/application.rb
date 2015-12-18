require 'sidekiq'
require 'json'
require 'app/fetcher'
require 'app/decorator'

Dir[ File.expand_path('workers/*.rb', __FILE__) ].each   { |file| require file }

class Application < Sinatra::Application

  set :protection, except: :path_traversal

  #get the events stored for a given period of time
  get "/data/events.json" do
    data     = Microsite::Fetcher.fetch("events")
    versions = Microsite::Fetcher.find_versions
    events   = Microsite::Decorator.as_event_list(data, versions)
    respond_with(events)
  end

  # gets you the startup time for a given period of time
  get "/data/startup_time.json" do
    data   = Microsite::Fetcher.fetch("start_time")
    events = Microsite::Decorator.as_chart(data)
    respond_with(events)
  end

  get "/bundles.json" do
    data = Microsite::Fetcher.fetch("bundles")
    respond_with(data)
  end

  get "/tests.json" do
    data = Microsite::Fetcher.fetch("tests")
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
