require 'spec_helper'

describe Percheron::Container::Actions::Create do

  let(:logger_double) { double('Logger') }

  let(:config) { Percheron::Config.new('./spec/fixtures/.percheron_valid.yml') }
  let(:stack) { Percheron::Stack.new(config, 'debian_jessie') }
  let(:container_name) { 'debian' }
  let(:container) { Percheron::Container::Main.new(config, stack, container_name) }

  let(:expected_opts) { {"name"=>"debian", "Image"=>"debian:1.0.0", "Hostname"=>"debian", "Env"=>[], "ExposedPorts"=>{"9999"=>{}}, "VolumesFrom"=>["/outside/container/path:/inside/container/path"]} }

  let(:docker_image_double) { double('Docker::Image') }
  let(:new_docker_image_double) { double('Docker::Image') }

  subject { described_class.new(container) }

  before do
    $logger = logger_double
  end

  describe '#execute!' do
    before do
      expect(logger_double).to receive(:debug).with("Creating 'debian' container")
      expect(subject).to receive(:base_dir).and_return('/tmp')
    end

    context 'when a Docker image does not exist' do
      let(:build_double) { double('Percheron::Container::Actions::Build') }

      it 'calls Container::Actions::Build#execute! AND creates a Docker::Container' do
        expect(Docker::Image).to receive(:get).with('debian:1.0.0').and_return(nil)
        expect(logger_double).to receive(:debug).with("Creating 'debian:1.0.0' image")
        expect(Percheron::Container::Actions::Build).to receive(:new).with(container).and_return(build_double)
        expect(build_double).to receive(:execute!)

        # FIXME: duplicate
        expect(Docker::Image).to receive(:get).with('debian:1.0.0').and_return(docker_image_double)
        expect(docker_image_double).to receive(:insert_local).with({"localPath"=>"/tmp/post_start_script.sh", "outputPath"=>"/tmp/post_start_script.sh"}).and_return(new_docker_image_double)
        expect(new_docker_image_double).to receive(:tag).with({:repo=>"debian", :tag=>"1.0.0", :force=>true})

        expect(Docker::Container).to receive(:create).with(expected_opts)
        subject.execute!
      end
    end

    context 'when a Docker image already exists' do
      it 'creates a Docker::Container' do
        expect(Docker::Image).to receive(:get).with('debian:1.0.0').and_return(docker_image_double)

        # FIXME: duplicate
        expect(Docker::Image).to receive(:get).with('debian:1.0.0').and_return(docker_image_double)
        expect(docker_image_double).to receive(:insert_local).with({"localPath"=>"/tmp/post_start_script.sh", "outputPath"=>"/tmp/post_start_script.sh"}).and_return(new_docker_image_double)
        expect(new_docker_image_double).to receive(:tag).with({:repo=>"debian", :tag=>"1.0.0", :force=>true})

        expect(Docker::Container).to receive(:create).with(expected_opts)
        subject.execute!
      end
    end
  end
end
