require 'spec_helper'

describe LogStash::PerfM::Runner do

  let(:config) { 'spec/fixtures/simple.conf' }
  let(:lines)  { load_fixture('simple_10.txt').split("\n") }

  let(:events) { 30 }
  let(:time)   { 10 }

  subject (:runner) { LogStash::PerfM::Runner.new(config) }

  let(:command) { [File.join(Dir.pwd, LogStash::PerfM::Runner::LOGSTASH_BIN), "-f", "spec/fixtures/simple.conf"]}

  it "invokes the logstash command" do
    Open3.should_receive(:popen3).with(*command).and_return(true)
    runner.run(events, 0, lines)
  end

  context "#execution with number of events" do

    let(:io)       { double("io", :puts => true, :flush => true) }
    subject(:feed) { runner.feed_input_with(events, 0, lines, io) }

    it "feeds in terms of events" do
      expect(runner).to receive(:feed_input_events).with(io, events, lines, LogStash::PerfM::Runner::LAST_MESSAGE)
      runner.feed_input_with(events, 0, lines, io)
    end

    it "feed the input stream with events.size+1 events" do
      expect(feed).to eq(events.to_i)
    end

  end
end
