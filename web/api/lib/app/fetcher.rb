require "elasticsearch"
require "elasticsearch-dsl"

module Microsite
  class Fetcher
    include Elasticsearch::DSL

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

    def query(params=nil)
      definition = (params.nil? ? @query_method.call : @query_method.call(params))
      client_search definition
    end

    def find_versions
      tests = client_search(query_bundles)
      tests["aggregations"]["series"]["buckets"].map do |bucket|
        bucket["key"]
      end
    end

    private

    def query_events(versions="master")
      search do
        query do
          filtered do
            query do
              match label: versions
            end
            filter do
              range :@timestamp do
                gte 'now-90d'
              end
            end
          end
        end
        aggregation :tests do
          terms do
            field 'name.raw'

            aggregation :timestamps do
              date_histogram do
                field    '@timestamp'
                interval 'day'
                format   'yyyy-MM-dd'

                aggregation :versions do
                  terms do
                    field 'label.raw'

                    aggregation :stats do
                      stats do
                        field 'events'
                      end
                    end
                  end
                end
              end
            end
          end
        end
        size 0
      end
    end

    def query_start_time(versions="master")
      search do
        query do
          filtered do
            query do
              match label: versions
            end
            filter do
              range :@timestamp do
                gte 'now-90d'
              end
            end
          end
        end

        aggregation :timestamps do
          date_histogram do
            field    '@timestamp'
            interval 'day'
            format   'yyyy-MM-dd'

            aggregation :test_cases do
              terms do
                field 'label.raw'
                size  10

                aggregation :stats do
                  stats do
                    field 'start time'
                  end
                end
              end
            end
          end
        end

        size 0
      end
    end

    def query_tests
      search do
        aggregation :series do
          terms do
            field 'name.raw'
            size  10
          end
        end
        size 0
      end
    end

    def query_bundles
      search do
        aggregation :series do
          terms field: "label.raw", order: { _term: "desc" }, size: 5
        end
        size 0
      end
    end

    def client_search(body)
      client.search(:index => "logstash-*", :body => body.to_hash)
    end

    def client
      @client ||= Elasticsearch::Client.new log: @debug
    end

  end
end
