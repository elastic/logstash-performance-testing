require 'spec_helper'

describe LSit::Executor::Suite do

  let(:suite_def)     { "spec/fixtures/basic_suite.rb" }
  let(:serial_runner) { double("DummySerialRunner", :read_input_file => "") }
  let(:runner)        { double("DummyRunner", :headers => [], :new => serial_runner) }

  subject(:manager) { LSit::Executor::Suite.new(suite_def, '.', runner) }

  it "run each test case in a serial maner" do
    expect(serial_runner).to receive(:run).with(0, 5, "").ordered { [[2000], 100, 3000] }
    expect(serial_runner).to receive(:run).with(0, 10, "").ordered { [[2000], 100, 3000] }
    manager.execute
  end
end

