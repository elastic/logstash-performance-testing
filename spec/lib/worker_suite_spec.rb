require 'spec_helper'

describe LogStash::PerformanceMeter::Core do

  let(:config)        { 'spec/fixtures/config.yml' }
  let(:logstash_home) { '.' }
  let(:suite_def)     { 'spec/fixtures/worker_basic_suite.rb' }
  let(:serial_runner) { double('DummySerialRunner') }
  let(:runner)        { LogStash::PerformanceMeter::Runner }
  let(:workers)       { 2 }

  let(:run_outcome)   { { :percentile => [2000] , :elapsed => 100, :events_count => 3000, :start_time => 12 } }
  subject(:manager) { LogStash::PerformanceMeter::Core.new(suite_def, logstash_home, config, runner) }

  context "with a valid configuration and worker threads set to 2" do
    before(:each) do
      expect(serial_runner).to receive(:run).with(0, 5, anything()).ordered  { run_outcome }
      expect(serial_runner).to receive(:run).with(0, 10, anything()).ordered { run_outcome }
    end
    context "using a file" do

      it "run each test case in a serial maner" do
        expect(runner).to receive(:new).with("spec/fixtures/simple.conf", workers, false, logstash_home).twice { serial_runner }
        manager.run
      end

    end

    context "without a file" do

      let(:config) { '' }

      it "run each test case as expected" do
        expect(runner).to receive(:read_input_file).with('simple_10.txt').twice { [] }
        expect(runner).to receive(:new).with("simple.conf", workers, false, logstash_home).twice { serial_runner }
        manager.run
      end

    end
  end
end
