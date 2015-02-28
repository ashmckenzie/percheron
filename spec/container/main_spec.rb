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

  subject { described_class.new(config, stack, container_name) }

  context 'when the Docker Container does not exist' do

    before do
      allow(Docker::Container).to receive(:get).with('debian').and_raise(Docker::Error::NotFoundError)
    end

    describe '#id' do
      it 'is N/A' do
        expect(subject.id).to eql('N/A')
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

    describe '#image' do
      it 'is a combination of name and version' do
        expect(subject.image).to eql('debian:1.0')
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

    describe '#stop!' do
    end

    describe '#start!' do
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
