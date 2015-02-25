require 'spec_helper'

describe Percheron::ContainerConfig do

  let(:config) do
    {
      name: 'container1',
      version: '1.0',
      dockerfile: './spec/fixtures/Dockerfile',
      ports: [ '9999:9999' ],
      dependant_container_names: [ 'dependant_container1' ],
      volumes: [ '/outside/container/path:/inside/container/path' ]
    }
  end

  let(:extra_data) { {} }
  let(:docker_container) { double('Docker::Container', Hashie::Mash.new(docker_data)) }
  let(:docker_data) do
    {
      info: {
        id: '1234567890123'
      }.merge(extra_data)
    }
  end

  subject { described_class.new(config) }

  before do
    allow(Docker::Container).to receive(:get).with('container1').and_return(docker_container)
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
      expect(subject.image).to eql('container1:1.0')
    end
  end

  describe '#exposed_ports' do
    it 'returns a hash of exposed ports' do
      expect(subject.exposed_ports).to eql({ '9999' => {} })
    end
  end

  describe '#links' do
    it 'returns an array of dependant container names' do
      expect(subject.links).to eql([ 'dependant_container1:dependant_container1' ])
    end
  end

  describe '#valid?' do
    context 'when config is invalid' do
      let(:config) { {} }

      it 'raises exception' do
        expect{ subject.valid? }.to raise_error(Percheron::Errors::ContainerConfigInvalid, '["Name is invalid", "Version is invalid", "Dockerfile is invalid"]')
      end
    end

    context 'when config is valid' do
      it 'is true' do
        expect(subject.valid?).to be(true)
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
