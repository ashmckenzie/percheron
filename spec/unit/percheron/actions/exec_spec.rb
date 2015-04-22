require 'unit/spec_helper'

describe Percheron::Actions::Exec do
  let(:logger) { double('Logger').as_null_object }
  let(:stop_action) { double('Percheron::Actions::Stop') }
  let(:start_action1) { double('Percheron::Actions::Start') }
  let(:start_action2) { double('Percheron::Actions::Start') }
  let(:docker_container) { double('Docker::Container').as_null_object }
  let(:docker_image) { double('Docker::Image') }

  let(:config) { Percheron::Config.new('./spec/unit/support/.percheron_valid.yml') }
  let(:stack) { Percheron::Stack.new(config, 'debian_jessie') }
  let(:container) { Percheron::Container.new(stack, 'debian', config.file_base_path) }
  let(:dependant_containers) { container.dependant_containers.values }
  let(:dependant_container) { dependant_containers.first }
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
      expect(container).to receive(:running?).twice.and_return(false)
      expect(container).to receive(:docker_container).and_return(docker_container).twice
    end

    it 'executes scripts' do
      expect(Percheron::Actions::Start).to receive(:new).with(dependant_container, dependant_containers: [], exec_scripts: true).and_return(start_action1)
      expect(Percheron::Actions::Start).to receive(:new).with(container, exec_scripts: false).and_return(start_action2)
      expect(start_action1).to receive(:execute!).and_return(dependant_container)
      expect(start_action2).to receive(:execute!).and_return(container)
      expect(docker_container).to receive(:exec).with(['/bin/sh', '/tmp/test.sh', '2>&1']).and_yield(:stdout, 'output from test.sh')
      subject.execute!
    end
  end
end
