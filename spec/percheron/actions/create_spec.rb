require 'spec_helper'

describe Percheron::Actions::Create do
  let(:logger) { double('Logger').as_null_object }
  let(:metastore) { double('Metastore::Cabinet') }
  let(:build_double) { double('Percheron::Actions::Build') }
  let(:exec_action) { double('Percheron::Actions::Exec') }

  let(:config) { Percheron::Config.new('./spec/support/.percheron_valid.yml') }
  let(:stack) { Percheron::Stack.new(config, 'debian_jessie') }
  let(:container) { Percheron::Container.new(config, stack, 'debian') }
  let(:dependant_containers) { container.dependant_containers }

  let(:debian_create_options) { {"name"=>"debian", "Image"=>"debian:1.0.0", "Hostname"=>"debian", "Env"=>[], "ExposedPorts"=>{"9999"=>{}}, "HostConfig"=>{"PortBindings"=>{"9999"=>[{"HostPort"=>"9999"}]}, "Links"=>["dependant_debian:dependant_debian"], "Binds"=>["/outside/container/path:/inside/container/path"]}} }

  subject { described_class.new(container) }

  before do
    $logger = logger
    $metastore = metastore
    allow(container).to receive(:dependant_containers).and_return(dependant_containers)
  end

  after do
    $logger = $metastore = nil
  end

  describe '#execute!' do
    before do
      expect(container).to receive(:exists?).and_return(container_exists)
    end

    context 'when a Docker Container does not exist' do
      let(:container_exists) { false }

      before do
        expect(container).to receive(:image_exists?).and_return(image_exists)
        expect(subject).to receive(:insert_files!).with(["./post_create_script2.sh"])
        expect(subject).to receive(:insert_files!).with(["./post_start_script2.sh"])
        expect(Docker::Container).to receive(:create).with(debian_create_options)
        expect(metastore).to receive(:set).with('stacks.debian_jessie.containers.debian.dockerfile_md5', '0b03152a88e90de1c5466d6484b8ce5b')
        expect(Percheron::Actions::Exec).to receive(:new).with(container, dependant_containers.values, ["./post_create_script2.sh"], 'POST create').and_return(exec_action)
        expect(exec_action).to receive(:execute!)
      end

      context 'when a Docker image does not exist' do
        let(:image_exists) { false }

        it 'calls Actions::Build#execute! AND creates a Docker::Container' do
          expect(Percheron::Actions::Build).to receive(:new).with(container).and_return(build_double)
          expect(build_double).to receive(:execute!)

          subject.execute!
        end
      end

      context 'when a Docker image already exists' do
        let(:image_exists) { true }

        it 'creates just a Docker::Container' do
          expect(Percheron::Actions::Build).to_not receive(:new).with(container)

          subject.execute!
        end
      end
    end

    context 'when a Docker container already exists' do
      let(:container_exists) { true }

      it 'creates a Docker::Container' do
        expect(logger).to receive(:debug).with("Container 'debian' already exists")

        subject.execute!
      end
    end
  end
end
