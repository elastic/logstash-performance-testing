require "elasticsearch"

module Microsite

  class Fetcher

    def initialize(type="")
      @query_method = method("query_#{type}".to_sym)
    end

    def self.fetch(type="")
      fetcher = self.new(type)
      fetcher.query
    end

    def query
      @query_method.call
    end

    private

    def query_events
      {type: :events}
    end

    def query_start_time
      { type: :start_time}
    end


    def client
      app_config = App.settings.app_config
      @client ||= Elasticsearch::Client.new(log: @debug, hosts: app_config["hosts"])
    end

  end

end
