require 'spec_helper'

describe Percheron::Container::Actions::Stop do

  let(:logger_double) { double('Logger') }

  let(:config) { Percheron::Config.new('./spec/fixtures/.percheron_valid.yml') }
  let(:stack) { Percheron::Stack.new(config, 'debian_jessie') }
  let(:container_name) { 'debian' }
  let(:container) { Percheron::Container::Main.new(config, stack, container_name) }

  subject { described_class.new(container) }

  before do
    $logger = logger_double
    expect(container).to receive(:running?).and_return(container_running)
  end

  describe '#execute!' do
    context 'when the Docker container is running' do
      let(:container_running) { true }
      let(:docker_container_double) { double('Docker::Container') }

      before do
        expect(container).to receive(:docker_container).and_return(docker_container_double)
      end

      it 'stops the container' do
        expect(logger_double).to receive(:debug).with("Stopping 'debian'")
        expect(docker_container_double).to receive(:stop!)
        subject.execute!
      end
    end

    context 'when the Docker container is not running' do
      let(:container_running) { false }

      it 'raises an exception' do
        expect(logger_double).to receive(:debug).with("Not stopping 'debian' container as it's not running")
        expect{ subject.execute! }.to raise_error(Percheron::Errors::ContainerNotRunning)
      end
    end
  end
end
