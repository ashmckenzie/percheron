require 'spec_helper'

describe Percheron::Container::Actions::Start do

  let(:logger_double) { double('Logger') }

  let(:config) { Percheron::Config.new('./spec/fixtures/.percheron_valid.yml') }
  let(:stack) { Percheron::Stack.new(config, 'debian_jessie') }
  let(:container_name) { 'debian' }
  let(:container) { Percheron::Container::Main.new(config, stack, container_name) }

  let(:expected_opts) { {"PortBindings"=>{"9999"=>[{"HostPort"=>"9999"}]}, "Links"=>["dependant_debian:dependant_debian"], "Binds"=>["/outside/container/path:/inside/container/path"]} }

  subject { described_class.new(container) }

  before do
    $logger = logger_double
    expect(container).to receive(:exists?).and_return(container_exists)
  end

  describe '#execute!' do
    context 'when a Docker container does not exist' do
      let(:container_exists) { false }

      it 'raises an exception' do
        expect{ subject.execute! }.to raise_error(Percheron::Errors::ContainerDoesNotExist)
      end
    end

    context 'when a Docker container already exists' do
      let(:container_exists) { true }
      let(:docker_container_double) { double('Docker::Container') }

      before do
        expect(container).to receive(:docker_container).and_return(docker_container_double).twice
      end

      it 'starts the container' do
        expect(logger_double).to receive(:debug).with("Starting 'debian'")
        expect(docker_container_double).to receive(:start!).with(expected_opts)

        expect(logger_double).to receive(:debug).with("Executing POST create '/bin/bash -x /tmp/post_start_script.sh 2>&1' for 'debian' container")
        expect(docker_container_double).to receive(:exec).with(["/bin/bash", "-x", "/tmp/post_start_script.sh", "2>&1"])

        subject.execute!
      end
    end
  end
end
