require 'unit/spec_helper'

describe Percheron::Unit do
  let(:extra_data) { {} }
  let(:container) { double('Docker::Container', Hashie::Mash.new(docker_data)) }
  let(:dependant_unit) { double('Docker::Container', Hashie::Mash.new(docker_data)) }
  let(:docker_data) do
    {
      name: 'debian',
      info: {
        id: '1234567890123',
        State: {
          Running: false
        }
      }.merge(extra_data)
    }
  end

  let(:config) { Percheron::Config.new('./spec/unit/support/.percheron_valid.yml') }
  let(:stack) { Percheron::Stack.new(config, 'debian_jessie') }

  let(:logger) { double('Logger').as_null_object }
  let(:metastore) { double('Metastore::Cabinet') }
  let(:stop_action) { double('Percheron::Actions::Stop') }
  let(:start_action) { double('Percheron::Actions::Start') }

  subject { described_class.new(config, stack, 'debian') }

  before do
    $logger = logger
    $metastore = metastore
  end

  after do
    $logger = $metastore = nil
  end

  context 'when the Docker Container does / does not exist' do
    describe '#hostname' do
      context 'when hostname is not explicitly defined' do
        it 'is valid' do
          expect(subject.hostname).to eql('debian')
        end
      end

      context 'when hostname is explicitly defined' do
        before do
          expect(stack.unit_configs).to receive(:[]).with('debian').and_return(Hashie::Mash.new(hostname: 'debian-hostname'))
        end

        it 'is valid' do
          expect(subject.hostname).to eql('debian-hostname')
        end
      end
    end

    describe '#image_name' do
      it 'is a combination of name and version' do
        expect(subject.image_name).to eql('debian_jessie_debian:1.0.0')
      end
    end

    describe '#image_repo' do
      context 'when the unit is not buildable' do
        subject { described_class.new(config, stack, 'debian_external') }

        context 'when the unit defines an image_name' do
          it 'returns image_name' do
            expect(subject.image_repo).to eql('debian')
          end
        end
      end

      context 'when the unit is a pseudo type' do
        subject { described_class.new(config, stack, 'debian_pseudo1') }

        it 'returns full_name' do
          expect(subject.image_repo).to eql('debian_jessie_debian_pseudo')
        end
      end
    end

    describe '#image_version' do
      context 'when a Dockerfile and Docker image is not defined' do
        before do
          expect(stack.unit_configs).to receive(:[]).with('debian').and_return(Hashie::Mash.new(name: 'debian'))
        end

        it 'raises an exception' do
          expect { subject.image_version }.to raise_error(Percheron::Errors::UnitInvalid)
        end
      end

      context 'when a Dockerfile is not defined but a Docker image is' do
        before do
          expect(stack.unit_configs).to receive(:[]).with('debian').and_return(Hashie::Mash.new(name: 'debian', docker_image: 'debian:jessie'))
        end

        it 'returns the Docker image version' do
          expect(subject.image_version).to eql('jessie')
        end
      end

      context 'when Docker image is defined without the tag (version)' do
        before do
          expect(stack.unit_configs).to receive(:[]).with('debian').and_return(Hashie::Mash.new(name: 'debian', docker_image: 'debian'))
        end

        it 'returns the :latest tag' do
          expect(subject.image_version).to eql('latest')
        end
      end

      context 'when a Dockerfile is defined and Docker image is not' do
        it 'returns the version' do
          expect(subject.image_version.to_s).to eql('1.0.0')
        end
      end
    end

    describe '#full_name' do
      it 'is a combination of stack name and unit name' do
        expect(subject.full_name).to eql('debian_jessie_debian')
      end
    end

    describe '#pseudo_full_name' do
      before do
        expect(stack.unit_configs).to receive(:[]).with('debian').and_return(Hashie::Mash.new(pseudo_name: 'pseudo_debian'))
      end

      it 'is a combination of stack name and unit name' do
        expect(subject.pseudo_full_name).to eql('debian_jessie_pseudo_debian')
      end
    end

    describe '#image' do
      context 'when the Docker Image does not exist' do
        before do
          expect(Docker::Image).to receive(:get).with('debian_jessie_debian:1.0.0').and_raise(Docker::Error::NotFoundError)
        end

        it 'returns NullImage' do
          expect(subject.image).to be_a(Percheron::NullImage)
        end
      end

      context 'when the Docker Image does exist' do
        let(:docker_image_double) { double('Docker::Image') }

        before do
          expect(Docker::Image).to receive(:get).with('debian_jessie_debian:1.0.0').and_return(docker_image_double)
        end

        it 'returns a Docker::Image' do
          expect(subject.image).to eql(docker_image_double)
        end
      end
    end

    describe '#labels' do
      it 'returns labels' do
        expect(subject.labels).to eql(version: '1.0.0', created_by: "Percheron #{Percheron::VERSION}")
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
      it 'returns an array of dependant unit names' do
        expect(subject.links).to eql([ 'debian_jessie_dependant_debian:dependant_debian' ])
      end
    end

    describe '#dependant_units' do
      it 'returns a Hash of dependant Containers' do
        expect(subject.dependant_units).to be_a(Hash)
      end

      it 'units the dependant_debian Container' do
        expect(subject.dependant_units['dependant_debian']).to be_a(Percheron::Unit)
      end
    end

    describe '#metastore_key' do
      it 'returns a unique key' do
        expect(subject.metastore_key).to eql('stacks.debian_jessie.units.debian')
      end
    end

    describe '#image_exists?' do
      context 'when the Docker Image does not exist' do
        before do
          expect(Docker::Image).to receive(:get).with('debian_jessie_debian:1.0.0').and_raise(Docker::Error::NotFoundError)
        end

        it 'returns false' do
          expect(subject.image_exists?).to be(false)
        end
      end

      context 'when the Docker Image does exist' do
        let(:docker_image_double) { double('Docker::Image', id: '5d6cb3bdb606') }

        before do
          expect(Docker::Image).to receive(:get).with('debian_jessie_debian:1.0.0').and_return(docker_image_double)
        end

        it 'returns true' do
          expect(subject.image_exists?).to be(true)
        end
      end
    end

    describe '#buildable?' do
      context 'when a Dockerfile is not defined but an image is' do
        before do
          expect(stack.unit_configs).to receive(:[]).with('debian').and_return(Hashie::Mash.new(image_name: 'debian:jessie'))
        end

        it 'returns false' do
          expect(subject.buildable?).to be(false)
        end
      end

      context 'when a Dockerfile is defined and Docker image is not' do
        it 'returns true' do
          expect(subject.buildable?).to be(true)
        end
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
      allow(Docker::Container).to receive(:get).with('debian_jessie_debian').and_raise(Docker::Error::NotFoundError)
      allow(Docker::Container).to receive(:get).with('debian_jessie_dependant_debian').and_raise(Docker::Error::NotFoundError)
      allow(subject).to receive(:exists?).and_return(false)
    end

    describe '#id' do
      it 'nil' do
        expect(subject.id).to be_nil
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

    describe '#container' do
      it 'returns a Percheron::NullUnit' do
        expect(subject.container).to be_a(Percheron::NullUnit)
      end
    end

    describe '#ip' do
      it 'returns nil' do
        expect(subject.ip).to be_nil
      end
    end

    describe '#update_dockerfile_md5!' do
      context 'when a Dockerfile is not defined but a Docker image is' do
        it 'updates the metastore' do
          expect(metastore).to receive(:set).with('stacks.debian_jessie.units.debian.dockerfile_md5', '0b03152a88e90de1c5466d6484b8ce5b')
          subject.update_dockerfile_md5!
        end
      end

      context 'when a Dockerfile is defined and Docker image is not' do
        it 'updates the metastore' do
          expect(metastore).to receive(:set).with('stacks.debian_jessie.units.debian.dockerfile_md5', '0b03152a88e90de1c5466d6484b8ce5b')
          subject.update_dockerfile_md5!
        end
      end
    end

    describe '#dockerfile_md5s_match?' do
      before do
        expect(metastore).to receive(:get).with('stacks.debian_jessie.units.debian.dockerfile_md5').and_return(dockerfile_md5)
      end

      context 'when the Docker unit has never been built' do
        let(:dockerfile_md5) { nil }

        it 'returns true' do
          expect(subject.dockerfile_md5s_match?).to be(true)
        end
      end

      context 'when the Docker unit has been built in the past' do
        let(:dockerfile_md5) { '1234' }

        it 'returns true' do
          expect(subject.dockerfile_md5s_match?).to be(false)
        end
      end
    end

    describe 'versions_match?' do
      it 'returns false' do
        expect(subject.versions_match?).to be(false)
      end
    end

    describe '#running?' do
      it 'is false' do
        expect(subject.running?).to be(false)
      end
    end
  end

  context 'when the Docker Container exists' do
    let(:extra_data) { { 'NetworkSettings' => { 'IPAddress' => '1.1.1.1' }, 'Config' => { 'Labels' => { 'version' => '1.0.0' } } } }

    before do
      allow(Docker::Container).to receive(:get).with('debian_jessie_debian').and_return(container)
      allow(Docker::Container).to receive(:get).with('debian_jessie_dependant_debian').and_return(dependant_unit)
      allow(subject).to receive(:exists?).and_return(true)
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

    describe '#container' do
      it 'returns a Percheron::Unit' do
        expect(subject.container).to be(container)
      end
    end

    describe '#ip' do
      it 'returns the IP' do
        expect(subject.ip).to eql('1.1.1.1')
      end
    end

    describe '#dockerfile_md5s_match?' do
      before do
        expect(metastore).to receive(:get).with('stacks.debian_jessie.units.debian.dockerfile_md5').and_return(dockerfile_md5)
      end

      context 'when the Docker unit needs to be rebuilt' do
        let(:dockerfile_md5) { 'abc123' }

        it 'returns false' do
          expect(subject.dockerfile_md5s_match?).to be(false)
        end
      end

      context 'when the Docker unit has been freshly built' do
        let(:dockerfile_md5) { '0b03152a88e90de1c5466d6484b8ce5b' }

        it 'returns true' do
          expect(subject.dockerfile_md5s_match?).to be(true)
        end
      end
    end

    describe 'versions_match?' do
      before do
        expect(subject).to receive(:unit_config).and_return(Hashie::Mash.new(name: 'debian', version: version)).exactly(3).times
      end

      context 'when the version has not been bumped' do
        let(:version) { '1.0.0' }

        it 'returns true' do
          expect(subject.versions_match?).to be(true)
        end
      end

      context 'when the version has been bumped' do
        let(:version) { '2.0.0' }

        it 'returns false' do
          expect(subject.versions_match?).to be(false)
        end
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
  end

  describe '#exists?' do
    before do
      expect(Docker::Container).to receive(:get).with('debian_jessie_debian').and_return(container)
    end

    context 'when the Container does not exist' do
      it 'returns false' do
        expect(container).to receive(:info).and_return({})
        expect(subject.exists?).to be(false)
      end
    end

    context 'when the Container does exist' do
      it 'returns true' do
        expect(container).to receive(:info).and_return(not: 'empty')
        expect(subject.exists?).to be(true)
      end
    end
  end
end
