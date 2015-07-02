require 'yaml'
require 'lsperfm/core'

module LogStash
  module PerfM

    extend self

    def invoke
      debug  = !!ENV['DEBUG']

      install_path  = ARGV.size > 1 ? ARGV[1] : Dir.pwd
      definition    = ARGV.size > 0 ? ARGV[0] : ""

      runner = LogStash::PerfM::Core.new(definition, install_path)
      runner.config = '.lsit' if File.exist?('.lsit.yml')
      puts runner.run(debug).join("\n")
    end

  end
end
