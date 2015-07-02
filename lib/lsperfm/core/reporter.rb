# encoding: utf-8

module LogStash
  module PerfM
    class Reporter
      def start
        @reporter = Thread.new do
          loop do
            $stderr.print '.'
            sleep 1
          end
        end
        self
      end

      def stop
        @reporter.kill
      end
    end
  end
end
