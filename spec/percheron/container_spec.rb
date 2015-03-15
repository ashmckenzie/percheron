require 'spec_helper'

describe Percheron::Container do
  let(:extra_data) { {} }
  let(:docker_container) { double('Docker::Container', Hashie::Mash.new(docker_data)) }
  let(:dependant_docker_container) { double('Docker::Container', Hashie::Mash.new(docker_data)) }
  let(:docker_data) do
    {
      info: {
        id: '1234567890123',
        State: {
          Running: false
        }
      }.merge(extra_data)
    }
  end

  let(:config) { Percheron::Config.new('./spec/support/.percheron_valid.yml') }
  let(:stack) { Percheron::Stack.new(config, 'debian_jessie') }

  let(:metastore) { double('Metastore::Cabinet') }
  let(:stop_action) { double('Percheron::Actions::Stop') }
  let(:start_action) { double('Percheron::Actions::Start') }

  subject { described_class.new(config, stack, 'debian') }

  before do
    $metastore = metastore
  end

  after do
    $metastore = nil
  end

  context 'when the Docker Container does / does not exist' do
    describe '#image_name' do
      it 'is a combination of name and version' do
        expect(subject.image_name).to eql('debian:1.0.0')
      end
    end

    describe '#image' do
      context 'when the Docker Image does not exist' do
        before do
          expect(Docker::Image).to receive(:get).with('debian:1.0.0').and_raise(Docker::Error::NotFoundError)
        end

        it 'returns nil' do
          expect(subject.image).to be(nil)
        end
      end

      context 'when the Docker Image does exist' do
        let(:docker_image_double) { double('Docker::Image') }

        before do
          expect(Docker::Image).to receive(:get).with('debian:1.0.0').and_return(docker_image_double)
        end

        it 'returns a Docker::Image' do
          expect(subject.image).to eql(docker_image_double)
        end
      end
    end

    describe '#dockerfile' do
      it 'returns a Pathname object' do
        expect(subject.dockerfile).to be_a(Pathname)
      end
    end

    describe '#exposed_ports' do
      it 'returns a hash of exposed ports' do
        expect(subject.exposed_ports).to eql('9999' => {})
      end
    end

    describe '#links' do
      it 'returns an array of dependant container names' do
        expect(subject.links).to eql([ 'dependant_debian:dependant_debian' ])
      end
    end

    describe '#dependant_containers' do
      it 'returns a Hash of dependant Containers' do
        expect(subject.dependant_containers).to be_a(Hash)
      end

      it 'containers the dependant_debian Container' do
        expect(subject.dependant_containers['dependant_debian']).to be_a(Percheron::Container)
      end
    end

    describe '#metastore_key' do
      it 'returns a unique key' do
        expect(subject.metastore_key).to eql('stacks.debian_jessie.containers.debian')
      end
    end

    describe '#current_dockerfile_md5' do
      it 'returns an MD5 hash' do
        expect(subject.current_dockerfile_md5).to eql('0b03152a88e90de1c5466d6484b8ce5b')
      end
    end

    describe '#dockerfile_md5' do
      it 'asks for the stored MD5 hash' do
        expect(metastore).to receive(:get).with('stacks.debian_jessie.containers.debian.dockerfile_md5')
        subject.dockerfile_md5
      end
    end

    describe '#image_exists?' do
      context 'when the Docker Image does not exist' do
        before do
          expect(Docker::Image).to receive(:get).with('debian:1.0.0').and_raise(Docker::Error::NotFoundError)
        end

        it 'returns false' do
          expect(subject.image_exists?).to be(false)
        end
      end

      context 'when the Docker Image does exist' do
        let(:docker_image_double) { double('Docker::Image') }

        before do
          expect(Docker::Image).to receive(:get).with('debian:1.0.0').and_return(docker_image_double)
        end

        it 'returns true' do
          expect(subject.image_exists?).to be(true)
        end
      end
    end

    describe '#dependant_containers?' do
      it 'returns true' do
        expect(subject.dependant_containers?).to be(true)
      end
    end

    describe '#valid?' do
      it 'returns true' do
        expect(subject.valid?).to be(true)
      end
    end
  end

  context 'when the Docker Container does not exist' do
    before do
      allow(Docker::Container).to receive(:get).with('debian').and_raise(Docker::Error::NotFoundError)
      allow(Docker::Container).to receive(:get).with('dependant_debian').and_raise(Docker::Error::NotFoundError)
    end

    describe '#id' do
      it 'is N/A' do
        expect(subject.id).to eql('N/A')
      end
    end

    describe '#built_version' do
      it 'returns a Semantic::Version object' do
        expect(subject.built_version).to be_a(Semantic::Version)
      end

      it "is '0.0.0'" do
        expect(subject.built_version.to_s).to eql('0.0.0')
      end
    end

    describe '#docker_container' do
      it 'returns a Percheron::NullContainer' do
        expect(subject.docker_container).to be_a(Percheron::NullContainer)
      end
    end

    describe '#running?' do
      it 'is false' do
        expect(subject.running?).to be(false)
      end
    end

    describe '#exists?' do
      it 'is false' do
        expect(subject.exists?).to be(false)
      end
    end
  end

  context 'when the Docker Container exists' do
    let(:extra_data) { { 'Config' => { 'Image' => 'test1:1.0.0' } } }

    before do
      allow(Docker::Container).to receive(:get).with('debian').and_return(docker_container)
      allow(Docker::Container).to receive(:get).with('dependant_debian').and_return(dependant_docker_container)
    end

    describe '#id' do
      it 'is 12 characters in length' do
        expect(subject.id.length).to eql(12)
      end

      it 'is valid' do
        expect(subject.id).to eql('123456789012')
      end
    end

    describe '#built_version' do
      it 'returns a Semantic::Version object' do
        expect(subject.built_version).to be_a(Semantic::Version)
      end

      it "is '1.0.0'" do
        expect(subject.built_version.to_s).to eql('1.0.0')
      end
    end

    describe '#docker_container' do
      it 'returns a Percheron::NullContainer' do
        expect(subject.docker_container).to be(docker_container)
      end
    end

    describe '#running?' do
      context 'when off' do
        let(:extra_data) { { 'State' => { 'Running' => false } } }

        it 'is false' do
          expect(subject.running?).to be(false)
        end
      end

      context 'when on' do
        let(:extra_data) { { 'State' => { 'Running' => true } } }

        it 'is true' do
          expect(subject.running?).to be(true)
        end
      end
    end

    describe '#exists?' do
      it 'is true' do
        expect(subject.exists?).to be(true)
      end
    end
  end
end
