require File.join(File.dirname(__FILE__), "config_manager" )

module Microsite

  class ConfigWorker
    include Sidekiq::Worker

    def perform(name, body)
      r = Microsite::ConfManager.new
      r.perform
    end
  end

end
