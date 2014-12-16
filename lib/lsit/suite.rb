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
          p, elapsed, events_count = manager.run(events, time, runner.read_input_file(test_input(test[:input])))
          lines << "#{test[:name]}, #{"%.2f" % elapsed}, #{events_count}, #{"%.0f" % (events_count / elapsed)},#{p.last}, #{"%.0f" % (p.reduce(:+) / p.size)}"
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

    end
  end
end
