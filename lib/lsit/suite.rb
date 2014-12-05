require 'lsit/reporter'

module LSit
  module Executor
    class Suite

      attr_reader :definition, :install_path

      def initialize(definition, install_path)
        @definition   = definition
        @install_path = install_path
      end

      def execute(debug=false)
        tests    = eval(IO.read(definition))
        lines    = ["name, #{Runner.headers.join(',')}"]
        reporter = Reporter.new.start
        tests.each do |test|
          events = test[:events].to_i
          time   = test[:time].to_i
          runner = Runner.new(test[:config], debug, install_path)
          p, elaspsed, events_count = runner.run(events, time, runner.read_input_file(test[:input]))
          lines << "#{test[:name]}, #{"%.2f" % elaspsed}, #{events_count}, #{"%.0f" % (events_count / elaspsed)},#{p.last}, #{"%.0f" % (p.reduce(:+) / p.size)}"
        end
        lines
      ensure
        reporter.stop if reporter
      end
    end
  end
end
