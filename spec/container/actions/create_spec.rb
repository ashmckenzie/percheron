require 'spec_helper'

describe Percheron::Container::Actions::Create do

  let(:logger_double) { double('Logger') }

  let(:config) { Percheron::Config.new('./spec/fixtures/.percheron_valid.yml') }
  let(:stack) { Percheron::Stack.new(config, 'debian_jessie') }
  let(:container_name) { 'debian' }
  let(:container) { Percheron::Container::Main.new(config, stack, container_name) }

  let(:expected_opts) { {"name"=>"debian", "Image"=>"debian:1.0.0", "Hostname"=>"debian", "Env"=>[], "ExposedPorts"=>{"9999"=>{}}, "VolumesFrom"=>["/outside/container/path:/inside/container/path"]} }

  subject { described_class.new(container) }

  before do
    $logger = logger_double
    expect(Docker::Image).to receive(:get).with('debian:1.0.0').and_return(image_exists)
  end

  describe '#execute!' do
    before do
      expect(logger_double).to receive(:debug).with("Creating 'debian' container")
    end

    context 'when a Docker image already exists' do
      let(:image_exists) { true }

      it 'creates a Docker::Container' do
        expect(Docker::Container).to receive(:create).with(expected_opts)
        subject.execute!
      end
    end

    context 'when a Docker image does not exist' do
      let(:image_exists) { false }
      let(:build_double) { double('Percheron::Container::Actions::Build') }

      before do
        expect(Percheron::Container::Actions::Build).to receive(:new).with(container).and_return(build_double)
        expect(logger_double).to receive(:debug).with("Creating 'debian:1.0.0' image")
      end

      it 'calls Container::Actions::Build#execute! AND creates a Docker::Container' do
        expect(build_double).to receive(:execute!)
        expect(Docker::Container).to receive(:create).with(expected_opts)
        subject.execute!
      end

    end
  end

end
