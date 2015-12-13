require 'timeout'
require 'net/http'
require 'thin'

# Start a simple Thin server to serve the application for Capybara
#
begin
  Net::HTTP.get( URI('http://localhost:8000') )
  STDERR.puts "\e[2mApplication already running...\e[0m"

rescue Errno::ECONNREFUSED
  STDERR.puts "\e[2mStarting the Rack server for the application...\e[0m"

  Timeout.timeout(10) do
    @pid = Process.fork do
      Thin::Logging.silent = true
      Thin::Server.start 8000, lambda { |env|
        if env['PATH_INFO'] == '/'
          [200, {'Content-Type' => 'text/html'}, File.new('../index.html')]
        else
          Rack::Directory.new('..').(env)
        end
      }
      end
  end

  at_exit do
    STDERR.puts "\e[2mStopping the Rack server with PID #{@pid}...\e[0m"
    Process.kill 'TERM', @pid
  end
end
