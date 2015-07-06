require File.join(File.dirname(__FILE__), "runner" )

module Microsite

  class TestWorker
    include Sidekiq::Worker

    def perform(name, body)
      r = Microsite::Runner.new
      r.perform
    end
  end

end
