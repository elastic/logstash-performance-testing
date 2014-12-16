require 'lsit/reporter'

module LSit

  class ConfigException < Exception; end

  module Executor
    class Suite

      attr_reader :definition, :install_path, :runner, :config

      def initialize(definition, install_path, config='', runner = Runner)
        @definition   = definition
        @install_path = install_path
        @runner       = runner
        @config       = load_config(config)
      end

      def execute(debug=false)
        tests    = eval(IO.read(definition))
        lines    = ["name, #{runner.headers.join(',')}"]
        reporter = Reporter.new.start
        tests.each do |test|
          events  = test[:events].to_i
          time    = test[:time].to_i

          manager = runner.new(test_config(test[:config]), debug, install_path)
          metrics = manager.run(events, time, runner.read_input_file(test_input(test[:input])))
          lines << formatter(test[:name], metrics)
        end
        lines
      rescue Errno::ENOENT => e
        raise ConfigException.new(e)
      ensure
        reporter.stop if reporter
      end

      def config=(config)
        @config = load_config(config)
      end

      private

      def load_config(config)
        ::YAML::load_file(config)['default'] rescue default_config
      end

      def test_config(file)
        File.join(config['path'], config['config'], file)
      end

      def test_input(file)
        File.join(config['path'], config['input'], file)
      end

      def default_config
        {'path' => '.', 'config' => '', 'input' => ''}
      end

      def formatter(test_name, args={})
        percentile =   args[:percentile]
        [
          "%s"   %           test_name,
          "%.2f" %   args[:start_time],
          "%.2f" %      args[:elapsed],
          "%.0f" % args[:events_count],
          "%.0f" % (args[:events_count] / args[:elapsed]),
          "%.2f" % percentile.last,
          "%.0f" % (percentile.reduce(:+) / percentile.size)
        ].join(',')
      end
    end
  end
end
