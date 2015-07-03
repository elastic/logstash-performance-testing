require 'spec_helper'

describe LogStash::PerfM::Core do

  let(:config)        { 'spec/fixtures/config.yml' }
  let(:logstash_home) { '.' }
  let(:suite_def)     { 'spec/fixtures/basic_suite.rb' }
  let(:serial_runner) { double('DummySerialRunner') }
  let(:runner)        { LogStash::PerfM::Runner }

  let(:run_outcome)   { { :percentile => [2000] , :elapsed => 100, :events_count => 3000, :start_time => 12 } }
  subject(:manager) { LogStash::PerfM::Core.new(suite_def, logstash_home, config, runner) }

  context "with a valid configuration" do
    before(:each) do
      expect(serial_runner).to receive(:run).with(0, 5, anything()).ordered  { run_outcome }
      expect(serial_runner).to receive(:run).with(0, 10, anything()).ordered { run_outcome }
    end
    context "using a file" do

      it "run each test case in a serial maner" do
        expect(runner).to receive(:new).with("spec/fixtures/simple.conf", false, logstash_home).twice { serial_runner }
        manager.run
      end

    end

    context "without a file" do

      let(:config) { '' }

      it "run each test case as expected" do
        expect(runner).to receive(:read_input_file).with('simple_10.txt').twice { [] }
        expect(runner).to receive(:new).with("simple.conf", false, logstash_home).twice { serial_runner }
        manager.run
      end

    end
  end

  context "with a wrong configuration" do

    let(:config)        { 'spec/fixtures/wrong_config.yml' }

    it "run each test case as expected" do
      expect(runner).to receive(:new).with("spec/wrong_fixture/simple.conf", false, logstash_home).once { serial_runner }
      expect { manager.run }.to raise_error(LogStash::PerfM::ConfigException)
    end
  end

end
