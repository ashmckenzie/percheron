require 'spec_helper'

describe Percheron::Actions::Start do

  let(:docker_container) { double('Docker::Container') }
  let(:logger) { double('Logger').as_null_object }
  let(:exec_action) { double('Percheron::Actions::Exec') }

  let(:config) { Percheron::Config.new('./spec/support/.percheron_valid.yml') }
  let(:stack) { Percheron::Stack.new(config, 'debian_jessie') }
  let(:container) { Percheron::Container.new(config, stack, 'debian') }
  let(:dependant_containers) { container.dependant_containers.values }

  subject { described_class.new(container, dependant_containers) }

  before do
    $logger = logger
  end

  after do
    $logger = nil
  end

  describe '#execute!' do

    let(:create_double) { double('Percheron::Actions::Create') }
    let(:recreate_double) { double('Percheron::Actions::Recreate') }

    before do
      expect(container).to receive(:running?).and_return(container_running)
      allow(Percheron::Actions::Exec).to receive(:new).with(container, dependant_containers, ["./post_start_script2.sh"], 'POST start').and_return(exec_action)
      allow(exec_action).to receive(:execute!)
    end

    context 'when the container is not running' do
      before do
        expect(container).to receive(:exists?).and_return(container_exists)
        allow(docker_container).to receive(:start!)
        expect(container).to receive(:docker_container).and_return(docker_container)
      end

      let(:container_running) { false }

      context 'when the container does not exist' do
        let(:container_exists) { false }

        before do
          expect(Percheron::Actions::Create).to receive(:new).with(container).and_return(create_double)
          allow(create_double).to receive(:execute!)
        end

        it 'should ask Actions::Create to execute' do
          expect(create_double).to receive(:execute!)
          subject.execute!
        end

        include_examples 'an Actions::Start'
      end

      context 'when the container does exist' do
        let(:container_exists) { true }

        before do
          expect(Percheron::Actions::Recreate).to receive(:new).with(container).and_return(recreate_double)
          allow(recreate_double).to receive(:execute!)
        end

        it 'should ask Actions::Recreate to execute' do
          expect(recreate_double).to receive(:execute!)
          subject.execute!
        end

        include_examples 'an Actions::Start'
      end
    end

    context 'when the container is running' do
      let(:container_exists) { true }
      let(:container_running) { true }

      before do
        expect(Percheron::Actions::Create).to receive(:new).with(container).and_return(create_double)
        allow(create_double).to receive(:execute!)
      end

      it 'does not try to start the Container' do
        expect(docker_container).to_not receive(:start!)
        subject.execute!
      end
    end
  end
end
