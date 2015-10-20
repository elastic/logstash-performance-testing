require 'helpers'
require 'json'
require 'app/charts'
require 'app/config'

class App < Sinatra::Application

  helpers AppHelpers

  get '/fetch_events.json' do
    data = Microsite::Charts.fetch("events")
    to_chartjs(data).to_json
  end

  get '/fetch_tps.json' do
    data = Microsite::Charts.fetch("avg top 20% tps")
    to_chartjs(data).to_json
  end

  get '/fetch_elapsed.json' do
    data = Microsite::Charts.fetch("elapsed")
    to_chartjs(data).to_json
  end

  get '/fetch_starttime.json' do
    data = Microsite::Charts.fetch("start time")
    to_chartjs(data).to_json
  end

  get '/fetch_events/:label.json' do |label|
    buckets = Microsite::Charts.fetch_per_bundle(label, "events")
    to_chartjs(buckets).to_json
  end

  get '/fetch_tps/:label.json' do |label|
    buckets = Microsite::Charts.fetch_per_bundle(label, "avg top 20% tps")
    to_chartjs(buckets).to_json
  end

  get '/fetch_events/test/:label.json' do |label|
    buckets = Microsite::Charts.fetch_per_test(label, "events")
    to_chartjs(buckets).to_json
  end

  get '/fetch_tps/test/:label.json' do |label|
    buckets = Microsite::Charts.fetch_per_test(label, "avg top 20% tps")
    to_chartjs(buckets).to_json
  end

  get '/tests.json' do
    labels = Microsite::Charts.tests
    labels["aggregations"]["series"]["buckets"].to_json
  end

  get '/bundles.json' do
    labels = Microsite::Charts.bundles
    labels["aggregations"]["series"]["buckets"].to_json
  end

  get '/timestamps.json' do
    labels = Microsite::Charts.timestamps
    labels["aggregations"]["timestamps"]["buckets"].to_json
  end

end
