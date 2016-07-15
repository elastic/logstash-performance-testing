require "yaml"
require "json"
require "elasticsearch"

module Microsite
  class ConfManager

    attr_reader :config_file, :git_path

    def initialize
      @config_file = ENV.fetch("LSPERF_CONFIG", ::File.join(::File.dirname(__FILE__), "..", "..", "config.yml"))
      @git_path    = ENV.fetch("LSPERF_GITPATH")
    end

    def perform
      update_git_repository
      update_config
    end

    private

    def update_git_repository
      system("cd #{git_path}; git pull")
    end

    def update_config
      payload = ::YAML.load_file(config_file)
      client.index  index: 'benchmarks-config', type: 'config', id: 1, body: payload
    end

    def client
      @client ||= ::Elasticsearch::Client.new log: @debug
    end

  end
end
