require 'spec_helper'

describe Percheron::Container::Main do

  let(:extra_data) { {} }
  let(:docker_container) { double('Docker::Container', Hashie::Mash.new(docker_data)) }
  let(:docker_data) do
    {
      info: {
        id: '1234567890123'
      }.merge(extra_data)
    }
  end

  let(:config) { Percheron::Config.new('./spec/fixtures/.percheron_valid.yml') }
  let(:stack) { Percheron::Stack.new(config, 'debian_jessie') }
  let(:container_name) { 'debian' }

  let(:logger_double) { double('Logger') }
  let(:stop_double) { double('Percheron::Container::Actions::Stop') }
  let(:start_double) { double('Percheron::Container::Actions::Start') }

  subject { described_class.new(config, stack, container_name) }

  before do
    $logger = logger_double
  end

  context 'when the Docker Container does OR does not exist' do
    describe '#image' do
      it 'is a combination of name and version' do
        expect(subject.image).to eql('debian:1.0.0')
      end
    end

    describe '#dockerfile' do
      it 'returns a Pathname object' do
        expect(subject.dockerfile).to be_a(Pathname)
      end
    end

    describe '#exposed_ports' do
      it 'returns a hash of exposed ports' do
        expect(subject.exposed_ports).to eql({ '9999' => {} })
      end
    end

    describe '#links' do
      it 'returns an array of dependant container names' do
        expect(subject.links).to eql([ 'dependant_debian:dependant_debian' ])
      end
    end

    describe '#restart!' do
      it 'asks Percheron::Container::Actions::Start to execute' do
        expect(subject).to receive(:stop!)
        expect(subject).to receive(:start!)
        subject.restart!
      end
    end

    describe '#valid?' do
      it 'is true' do
        expect(subject.valid?).to be(true)
      end
    end
  end

  context 'when the Docker Container does not exist' do
    before do
      allow(Docker::Container).to receive(:get).with('debian').and_raise(Docker::Error::NotFoundError)
    end

    describe '#id' do
      it 'is N/A' do
        expect(subject.id).to eql('N/A')
      end
    end

    describe '#built_version' do
      it 'returns nil' do
        expect(subject.built_version).to be_nil
      end
    end

    describe '#docker_container' do
      it 'returns a Percheron::Container::Null' do
        expect(subject.docker_container).to be_a(Percheron::Container::Null)
      end
    end

    describe '#stop!' do
      before do
        expect(Percheron::Container::Actions::Stop).to receive(:new).with(subject).and_return(stop_double)
      end

      it 'asks Container::Actions::Stop to execute' do
        expect(stop_double).to receive(:execute!).and_raise(Percheron::Errors::ContainerNotRunning)
        expect(logger_double).to receive(:debug).with("Container 'debian' is not running")
        subject.stop!
      end
    end

    describe '#start!' do
      before do
        expect(logger_double).to receive(:warn).with("Not recreating 'debian' container as it does not exist")
        expect(Percheron::Container::Actions::Start).to receive(:new).with(subject).and_return(start_double)
      end

      it 'asks Percheron::Container::Actions::Start to execute' do
        expect(subject).to receive(:create!)
        expect(start_double).to receive(:execute!)
        subject.start!
      end
    end

    describe '#create!' do
      let(:create_double) { double('Percheron::Container::Actions::Create') }

      before do
        expect(logger_double).to receive(:debug).with("Container 'debian' does not exist, creating")
        expect(Percheron::Container::Actions::Create).to receive(:new).with(subject).and_return(create_double)
      end

      it 'asks Percheron::Container::Actions::Create to execute' do
        expect(create_double).to receive(:execute!)
        subject.create!
      end
    end

    describe '#recreate!' do
      before do
        expect(logger_double).to receive(:warn).with("Not recreating 'debian' container as it does not exist")
      end

      it 'warns the container does not exist ' do
        subject.recreate!
      end
    end

    describe '#recreatable?' do
      it 'returns false' do
        expect(subject.recreatable?).to be(false)
      end
    end

    describe '#recreate?' do
      it 'returns false' do
        expect(subject.recreate?).to be(false)
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
      it 'returns a Percheron::Container::Null' do
        expect(subject.docker_container).to be(docker_container)
      end
    end

    describe '#stop!' do
      before do
        expect(Percheron::Container::Actions::Stop).to receive(:new).with(subject).and_return(stop_double)
      end

      it 'asks Percheron::Container::Actions::Stop to execute' do
        expect(stop_double).to receive(:execute!)
        subject.stop!
      end
    end

    describe '#start!' do
      before do
        expect(logger_double).to receive(:warn).with("Not creating 'debian' container as it already exists")
        expect(logger_double).to receive(:debug).with("Container 'debian' does not need to be recreated")
        expect(Percheron::Container::Actions::Start).to receive(:new).with(subject).and_return(start_double)
      end

      it 'asks Percheron::Container::Actions::Start to execute' do
        expect(start_double).to receive(:execute!)
        subject.start!
      end
    end

    describe '#create!' do
      before do
        expect(logger_double).to receive(:warn).with("Not creating 'debian' container as it already exists")
      end

      it 'warns the container already exists' do
        subject.create!
      end
    end

    describe '#recreate!' do
      before do
        expect(subject).to receive(:recreate?).and_return(recreate)
      end

      context 'when #recreate? is false' do
        let(:recreate) { false }

        before do
          expect(subject).to receive(:recreatable?).and_return(recreatable)
        end

        context 'when not #recreatable? is false' do
          let(:recreatable) { false }

          it 'debug logs that the container does not need to recreated' do
            expect(logger_double).to receive(:debug).with("Container 'debian' does not need to be recreated")
            subject.recreate!
          end
        end

        context 'when not #recreatable? is true' do
          let(:recreatable) { true }

          it "warns the container's MD5's do not match" do
            expect(logger_double).to receive(:warn).with("Container 'debian' MD5's do not match, consider recreating")
            subject.recreate!
          end
        end
      end

      context 'when #recreate? is true' do
        let(:recreate) { true }
        let(:recreate_double) { double('Percheron::Container::Actions::Recreate') }

        before do
          expect(logger_double).to receive(:warn).with("Container 'debian' exists and will be recreated")
          expect(Percheron::Container::Actions::Recreate).to receive(:new).with(subject).and_return(recreate_double)
        end

        it 'asks Percheron::Container::Actions::Recreate to execute' do
          expect(recreate_double).to receive(:execute!)
          subject.recreate!
        end
      end
    end

    describe '#recreatable?' do
      context "when the MD5's of the stored and current Dockerfile do not match" do
        before do
          expect(subject).to receive(:dockerfile_md5).and_return('1234567890')
        end

        it 'returns true' do
          expect(subject.recreatable?).to be(true)
        end
      end

      context "when the MD5's of the stored and current Dockerfile match" do
        it 'returns false' do
          expect(subject.recreatable?).to be(false)
        end
      end
    end

    describe '#recreate?' do
      context 'when not #recreatable? is false' do
        before do
          expect(subject).to receive(:recreatable?).and_return(false)
        end

        it 'returns false' do
          expect(subject.recreate?).to be(false)
        end
      end

      context 'when #recreatable? is true' do
        before do
          expect(subject).to receive(:recreatable?).and_return(true)
        end

        context 'when version > built_version is false' do
          before do
            expect(subject).to receive(:version).and_return(1)
            expect(subject).to receive(:built_version).and_return(1)
          end

          it 'returns false' do
            expect(subject.recreate?).to be(false)
          end
        end

        context 'when version > built_version is true' do
          before do
            expect(subject).to receive(:version).and_return(2)
            expect(subject).to receive(:built_version).and_return(1)
          end

          context 'when #auto_recreate? is false (default)' do
            before do
              expect(subject).to receive(:auto_recreate?).and_return(false)
            end

            it 'returns false' do
              expect(subject.recreate?).to be(false)
            end
          end

          context 'when #auto_recreate? is true' do
            before do
              expect(subject).to receive(:auto_recreate?).and_return(true)
            end

            it 'returns true' do
              expect(subject.recreate?).to be(true)
            end
          end
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

    describe '#exists?' do
      it 'is true' do
        expect(subject.exists?).to be(true)
      end
    end
  end
end
