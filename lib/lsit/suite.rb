require 'lsit/reporter'

module LSit
  module Executor
    class Suite

      attr_reader :definition, :install_path, :runner

      def initialize(definition, install_path, runner = Runner)
        @definition   = definition
        @install_path = install_path
        @runner       = runner
      end

      def execute(debug=false)
        tests    = eval(IO.read(definition))
        lines    = ["name, #{runner.headers.join(',')}"]
        reporter = Reporter.new.start
        tests.each do |test|
          events  = test[:events].to_i
          time    = test[:time].to_i
          manager = runner.new(test[:config], debug, install_path)
          metrics = manager.run(events, time, manager.read_input_file(test[:input]))
          lines << formatter(test[:name], metrics)
        end
        lines
      ensure
        reporter.stop if reporter
      end

      private

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
