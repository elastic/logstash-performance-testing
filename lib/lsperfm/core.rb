require 'lsperfm/core/reporter'
require 'lsperfm/core/run'

module LogStash::PerformanceMeter

  class ConfigException < Exception; end

  class Core

    attr_reader :definition, :install_path, :runner, :config

    def initialize(definition, install_path, config='', runner = LogStash::PerformanceMeter::Runner)
      @definition   = definition
      @install_path = install_path
      @runner       = runner
      @config       = load_config(config)
    end

    def run(debug=false, headers=false)
      tests    = load_tests(definition)
      lines    = (headers ? ["name, #{runner.headers.join(',')}"] : [])
      reporter = LogStash::PerformanceMeter::Reporter.new.start
      tests.each do |test|
        events  = test[:events].to_i
        time    = test[:time].to_i
        workers = test[:workers] ? test[:workers].to_s : "1"

        manager = runner.new(find_test_config(test[:config]), workers, debug, install_path)
        metrics = manager.run(events, time, runner.read_input_file(find_test_input(test[:input])))
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

    def load_tests(definition)
      return load_default_tests if definition.empty?
      eval(IO.read(definition))
    end

    def load_default_tests
      require 'lsperfm/defaults/suite.rb'
      LogStash::PerformanceMeter::DEFAULT_SUITE
    end

    def load_config(config)
      ::YAML::load_file(config)['default'] rescue {}
    end

    def find_test_config(file)
      return file if config.empty?
      File.join(config['path'], config['config'], file)
    end

    def find_test_input(file)
      return file if config.empty?
      File.join(config['path'], config['input'], file)
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
