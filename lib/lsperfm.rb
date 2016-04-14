require 'yaml'
require 'lsperfm/core'
require 'terminal-table'

module LogStash
  module PerformanceMeter

    extend self

    def invoke
      debug           = 'false' != ENV.fetch('DEBUG', 'false')
      display_headers = 'false' != ENV.fetch('HEADERS', 'true')
      table_output    = 'false' != ENV.fetch('TABLE_OUTPUT', 'false')

      install_path    = ARGV.size > 1 ? ARGV[1] : Dir.pwd
      definition      = ARGV.size > 0 ? ARGV[0] : ""

      runner = LogStash::PerformanceMeter::Core.new(definition, install_path)
      runner.config = '.lsperfm' if File.exist?('.lsperfm.yml')

      results = runner.run(debug)
      headings = results.slice!(0)

      puts ''
      if table_output
        table = Terminal::Table.new
        table.headings = headings.split(',') if display_headers
        table.rows = results.map { |result| result.split(',') }

        puts table
      else
        puts headings if display_headers
        puts results.join('\n')
      end
    end

  end
end
