require 'yaml'
require 'lsperfm/core'

module LogStash
  module PerformanceMeter

    extend self

    def invoke
      debug   = !!ENV['DEBUG']
      headers = !!ENV['HEADERS']

      install_path  = ARGV.size > 1 ? ARGV[1] : Dir.pwd
      definition    = ARGV.size > 0 ? ARGV[0] : ""

      runner = LogStash::PerformanceMeter::Core.new(definition, install_path)
      runner.config = '.lsit' if File.exist?('.lsit.yml')
      puts runner.run(debug, headers).join("\n")
    end

  end
end
