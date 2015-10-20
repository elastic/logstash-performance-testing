require 'yaml'

module Microsite
  class Config

    def initialize(data)
      @data = data
    end

    def self.load
      file = File.join(File.dirname(__FILE__), "../../config.yml")
      data = YAML.load_file(file)
      self.new(data)
    end

    def method_missing(method, *args, &block)
      @data.send(method, *args, &block)
    end

  end
end
