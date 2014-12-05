require 'spec_helper'

describe Runner do

  let(:config) { 'spec/fixtures/simple.conf' }
  let(:lines)  { load_fixture 'simple_10.txt' }

  let(:events) { 30 }
  let(:time)   { 10 }

  subject (:runner) { Runner.new(config) }

  context "#execution with number of events" do

    let(:command) { [Runner::LOGSTASH_BIN, "-f", "spec/fixtures/simple.conf"]}

    it "should invoke the logstash command" do
      Open3.should_receive(:popen3).with(*command).and_return(true)
      runner.run(events, 0, lines)
    end

  end
end
