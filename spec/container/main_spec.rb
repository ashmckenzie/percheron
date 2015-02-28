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
        expect(subject.image).to eql('debian:1.0')
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
      let(:create_double) { double('Percheron::Container::Actions::Create') }

      before do
        expect(Percheron::Container::Actions::Create).to receive(:new).with(subject).and_return(create_double)
        expect(Percheron::Container::Actions::Start).to receive(:new).with(subject).and_return(start_double)
      end

      it 'asks Percheron::Container::Actions::Start to execute' do
        expect(create_double).to receive(:execute!)
        expect(start_double).to receive(:execute!)
        subject.start!
      end
    end

    describe '#docker_container' do
      it 'returns a Percheron::Container::Null' do
        expect(subject.docker_container).to be_a(Percheron::Container::Null)
      end
    end

    describe '#running?' do
      it 'is false' do
        expect(subject.running?).to be(false)
      end
    end

  end

  context 'when the Docker Container exists' do

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
        expect(Percheron::Container::Actions::Start).to receive(:new).with(subject).and_return(start_double)
      end

      it 'asks Percheron::Container::Actions::Start to execute' do
        expect(start_double).to receive(:execute!)
        subject.start!
      end
    end

    describe '#valid?' do
      it 'is true' do
        expect(subject.valid?).to be(true)
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

end
