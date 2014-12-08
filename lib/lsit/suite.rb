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
          p, elapsed, events_count = manager.run(events, time, manager.read_input_file(test[:input]))
          lines << "#{test[:name]}, #{"%.2f" % elapsed}, #{events_count}, #{"%.0f" % (events_count / elapsed)},#{p.last}, #{"%.0f" % (p.reduce(:+) / p.size)}"
        end
        lines
      ensure
        reporter.stop if reporter
      end
    end
  end
end
