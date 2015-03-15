require 'spec_helper'

describe Percheron::Actions::Exec do

  let(:logger) { double('Logger').as_null_object }
  let(:stop_action) { double('Percheron::Actions::Stop') }
  let(:start_action) { double('Percheron::Actions::Start') }
  let(:docker_container) { double('Docker::Container') }

  let(:config) { Percheron::Config.new('./spec/support/.percheron_valid.yml') }
  let(:stack) { Percheron::Stack.new(config, 'debian_jessie') }
  let(:container) { Percheron::Container.new(config, stack, 'debian') }
  let(:dependant_containers) { container.dependant_containers.values }
  let(:dependant_container) { dependant_containers.first }
  let(:started_containers) { dependant_containers }
  let(:scripts) { [ '/tmp/test.sh' ] }

  subject { described_class.new(container, dependant_containers, scripts, 'TEST') }

  before do
    $logger = logger
  end

  after do
    $logger = nil
  end

  describe '#execute!' do

    before do
      expect(container).to receive(:running?).and_return(false)
      expect(container).to receive(:docker_container).and_return(docker_container)
    end

    it 'executes scripts' do
      expect(subject).to receive(:start_containers!).with(dependant_containers).and_return(started_containers)

      expect(Percheron::Actions::Start).to receive(:new).with(container, exec_scripts: false).and_return(start_action)
      expect(start_action).to receive(:execute!).and_return(started_containers)

      expect(docker_container).to receive(:exec).with(["/bin/bash", "-x", "/tmp/test.sh", "2>&1"]).and_yield(:stdout, 'output from test.sh')
      expect(logger).to receive(:debug).with('stdout: output from test.sh')

      expect(Percheron::Actions::Stop).to receive(:new).with(container).and_return(stop_action)
      expect(stop_action).to receive(:execute!)

      expect(subject).to receive(:stop_containers!).with(started_containers)

      subject.execute!
    end
  end
end
