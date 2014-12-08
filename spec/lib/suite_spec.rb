require 'spec_helper'

describe LSit::Executor::Suite do

  let(:config)        { 'spec/fixtures/config.yml' }
  let(:logstash_home) { '.' }
  let(:suite_def)     { 'spec/fixtures/basic_suite.rb' }
  let(:serial_runner) { double('DummySerialRunner', :read_input_file => '') }
  let(:runner)        { double('DummyRunner', :headers => [], :new => serial_runner) }

  subject(:manager) { LSit::Executor::Suite.new(suite_def, logstash_home, config, runner) }

  it "run each test case in a serial maner" do
    expect(runner).to receive(:new).with("spec/fixture/simple.conf", false, logstash_home) { serial_runner }
    expect(serial_runner).to receive(:run).with(0, 5, "").ordered { [[2000], 100, 3000] }
    expect(serial_runner).to receive(:run).with(0, 10, "").ordered { [[2000], 100, 3000] }
    manager.execute
  end
end

