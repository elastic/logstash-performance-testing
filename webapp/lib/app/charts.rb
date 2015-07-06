require 'jbuilder'
require 'elasticsearch'
require 'app/query_builder'

module Microsite

  class Charts

    def self.fetch(attribute)
      body = QueryBuilder.filtered_query(:gte => "now-7d")
      body[:size] = 0
      body[:aggs] = QueryBuilder.histogram[:aggs]
      body[:aggs][:timestamps][:aggs] = QueryBuilder.agggreation("label.raw", attribute)[:aggs]
      client.search(:index => 'logstash-*', :body => body)
    end

    def self.fetch_per_bundle(bundle, attribute)
      body = QueryBuilder.filtered_query(:field => "label.raw", :value => bundle, :gte => "now-7d")
      body[:size] = 0
      body[:aggs] = QueryBuilder.histogram[:aggs]
      body[:aggs][:timestamps][:aggs] = QueryBuilder.agggreation("name.raw", attribute)[:aggs]
      client.search(:index => 'logstash-*', :body => body)
    end

    def self.fetch_per_test(test, attribute)
      body = QueryBuilder.filtered_query(:field => "name.raw", :value => test, :gte => "now-7d")
      body[:size] = 0
      body[:aggs] = QueryBuilder.histogram[:aggs]
      body[:aggs][:timestamps][:aggs] = QueryBuilder.agggreation("label.raw", attribute)[:aggs]
      client.search(:index => 'logstash-*', :body => body)
    end

    def self.tests
      body = Jbuilder.encode do |json|
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
      client.search(:index => 'logstash-*', :body => body)
    end

    def self.bundles
      body = Jbuilder.encode do |json|
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
      client.search(:index => 'logstash-*', :body => body)
    end

    def self.timestamps
      body = Jbuilder.encode do |json|
        json.size 0
        json.aggs do
          json.timestamps do
            json.terms do
              json.field '@timestamp'
              json.size 10
            end
          end
        end
      end
      client.search(:index => 'logstash-*', :body => body)
    end


    private

    def self.client
      app_config = App.settings.app_config
      @client ||= Elasticsearch::Client.new(log: @debug, hosts: app_config["hosts"])
    end

  end
end
