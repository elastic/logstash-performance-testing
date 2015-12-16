require "elasticsearch"
require "app/query"
require 'jbuilder'

module Microsite

  class Fetcher
    attr_reader :time_frame

    def initialize(type="")
      @time_frame   = "now-90d"
      @query_method = method("query_#{type}".to_sym)
    end

    def self.fetch(type="")
      fetcher  = self.new(type)
      fetcher.query
    end

    def self.find_versions
      fetcher = self.new("events")
      fetcher.find_versions
    end

    def query
      definition = @query_method.call
      client_search definition
    end

    def find_versions
      tests = client_search(query_bundles)
      tests["aggregations"]["series"]["buckets"].map do |bucket|
        bucket["key"]
      end
    end

    private

    ## todo we should transform this to a proper elasticsearch-dsl
    def query_events
     { "query" => {
        "filtered" =>  {
          "filter" => {
            "range"=> {
              "@timestamp" => {
                "gte" => "now-90d"
              }
            }
          }
        }
      },
      "size" => 0,
      "aggs" => {
        "tests" => {
          "terms" => {
            "field" => "name.raw"
          },
          "aggs" => {
            "timestamps" => {
              "date_histogram" => {
                "field" => "@timestamp",
                "interval" => "day",
                "format" => "yyyy-MM-dd"
              },
              "aggs" => {
                "versions" => {
                  "terms" => {
                    "field"=> "label.raw"
                  },
                  "aggs" => {
                     "stats" => {
                       "stats" => { "field" => "events" }
                     }
                  }
                }
              }
            }
          }
        }
      }}
    end

    ## todo we should transform this to a proper elasticsearch-dsl
    def query_start_time
      body = QueryBuilder.filtered_query(:gte => time_frame)
      body[:size] = 0
      body[:aggs] = QueryBuilder.histogram[:aggs]
      body[:aggs][:timestamps][:aggs] = QueryBuilder.agggreation("label.raw", "start time")[:aggs]
      body
    end

    def query_tests
      Jbuilder.encode do |json|
        json.size 0
        json.aggs do
          json.series do
            json.terms do
              json.field 'name.raw'
              json.size 10
            end
          end
        end
      end
    end

    def query_bundles
      Jbuilder.encode do |json|
        json.size 0
        json.aggs do
          json.series do
            json.terms do
              json.field 'label.raw'
              json.size 10
            end
          end
        end
      end
    end

    def client_search(body)
      client.search(:index => "logstash-*", :body => body)
    end

    def client
      app_config = App.settings.app_config
      @client ||= Elasticsearch::Client.new(log: @debug, hosts: app_config["hosts"])
    end

  end

end
