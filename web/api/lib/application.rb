require 'sinatra'
require 'sidekiq'
require 'json'

require 'app/fetcher'
require 'app/decorator'

Dir[ File.expand_path('workers/*.rb', __FILE__) ].each   { |file| require file }

class Application < Sinatra::Application

  set :protection, except: :path_traversal

  before do
    headers(
      'Access-Control-Allow-Origin'  => '*',
      'Access-Control-Allow-Methods' => [:post, :get, :options],
      'Access-Control-Allow-Headers' => ["*", "Content-Type", "Accept", "AUTHORIZATION", "Cache-Control"].join(', ')
    )
  end

  get "/" do
    prefix = request.env['HTTP_X_PROXY_CLIENT'] == 'nginx' ? '/api' : ''
    host = "#{request.scheme}://#{request.host_with_port}"
    respond_with events_url: "#{host}#{prefix}/events.json",
                 startup_time_url: "#{host}#{prefix}/startup_time.json"
  end

  #get the events stored for a given period of time
  get "/events.json" do
    fetcher  = Microsite::Fetcher.new("events")
    versions = Microsite::Fetcher.find_versions
    data     = fetcher.query(versions.join(' '))
    events   = Microsite::Decorator.as_event_list(data, versions)
    respond_with(events)
  end

  # gets you the startup time for a given period of time
  get "/startup_time.json" do
    fetcher  = Microsite::Fetcher.new("start_time")
    versions = Microsite::Fetcher.find_versions
    data     = fetcher.query(versions.join(' '))
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

  # hook that runs the configuration update process
  post "/hook/pull_config" do
    body = JSON.parse(request.body.read)
    Microsite::ConfManager.perform_async('config_pull_hook', body)
  end

  private

  def respond_with(data={})
    halt 404 if data.empty?
    data.to_json
  end
end

Application.run! if __FILE__ == $0
