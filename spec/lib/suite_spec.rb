require 'spec_helper'

describe LSit::Executor::Suite do

  let(:suite_def)     { "spec/fixtures/basic_suite.rb" }
  let(:serial_runner) { double("DummySerialRunner", :read_input_file => "") }
  let(:runner)        { double("DummyRunner", :headers => [], :new => serial_runner) }

  let(:run_outcome)   { { :p => [2000] , :elapsed => 100, :events_count => 3000, :start_time => 12 } }
  subject(:manager)   { LSit::Executor::Suite.new(suite_def, '.', runner) }

  it "run each test case in a serial maner" do
    expect(serial_runner).to receive(:run).with(0, 5, "").ordered { run_outcome }
    expect(serial_runner).to receive(:run).with(0, 10, "").ordered { run_outcome }
    manager.execute
  end
end

