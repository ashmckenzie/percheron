require 'spec_helper'

describe Percheron::Container::Actions::Recreate do

  let(:logger_double) { double('Logger') }

  let(:config) { Percheron::Config.new('./spec/fixtures/.percheron_valid.yml') }
  let(:stack) { Percheron::Stack.new(config, 'debian_jessie') }
  let(:container_name) { 'debian' }
  let(:container) { Percheron::Container::Main.new(config, stack, container_name) }

  subject { described_class.new(container) }

  before do
    Timecop.freeze(Time.local(1990))
    $logger = logger_double
  end

  after do
    Timecop.return
  end

  describe '#execute!' do

    context 'when the temporary Docker container does not exist' do

      let(:docker_container_double) { double('Docker::Container') }
      let(:wip_docker_container_double) { double('Docker::Container') }
      let(:build_double) { double('Percheron::Container::Actions::Build') }
      let(:stop_double) { double('Percheron::Container::Actions::Stop') }

      let(:expected_opts) { {"name"=>"debian_wip", "Image"=>"debian:1.0.0", "Hostname"=>"debian", "Env"=>[], "ExposedPorts"=>{"9999"=>{}}, "VolumesFrom"=>["/outside/container/path:/inside/container/path"]} }

      before do
        expect(Docker::Container).to receive(:get).with('debian_wip').and_raise(Docker::Error::NotFoundError)

        expect(container).to receive(:docker_container).and_return(docker_container_double)
        expect(container).to receive(:running?).and_return(running).at_least(:once)
        expect(Docker::Image).to receive(:get).with('debian:1.0.0').and_return(image_exists)
        expect(Docker::Container).to receive(:get).with('debian_wip').and_return(wip_docker_container_double)
        expect(Docker::Container).to receive(:create).with(expected_opts)
        expect(logger_double).to receive(:debug).with("Recreating 'debian' container as 'debian_wip'")
        expect(logger_double).to receive(:debug).with("Renaming 'debian' container to 'debian_19900101000000'")
        expect(docker_container_double).to receive(:rename).with('debian_19900101000000')
        expect(logger_double).to receive(:debug).with("Renaming 'debian_wip' container to 'debian'")
        expect(wip_docker_container_double).to receive(:rename).with('debian')
      end

      context 'when an image does not exist' do
        let(:image_exists) { false }

        before do
          expect(logger_double).to receive(:debug).with("Creating 'debian:1.0.0' image")
          expect(Percheron::Container::Actions::Build).to receive(:new).with(container).and_return(build_double)
          expect(build_double).to receive(:execute!)
        end

        include_examples 'an Actions::Recreate'
      end

      context 'when an image already exists' do
        let(:image_exists) { true }

        include_examples 'an Actions::Recreate'
      end
    end

    context 'when the temporary Docker container does exist' do
      let(:temporary_container_double) { double('Docker::Container', info: {}) }

      before do
        expect(Docker::Container).to receive(:get).with('debian_wip').and_return(temporary_container_double)
      end

      it 'raises warns that the temporary container already exists' do
        expect(logger_double).to receive(:warn).with("Not recreating 'debian' container as 'debian_wip' because 'debian_wip' already exists")
        subject.execute!
      end
    end
  end

end
