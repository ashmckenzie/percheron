require 'spec_helper'

describe Percheron::Config do

  let(:config_file) { './spec/fixtures/.percheron.yml' }

  subject { described_class.new(config_file) }

  describe '#valid?' do
    context 'when config file is invalid' do
      let(:config_file) { './spec/fixtures/missing.yml' }

      it 'raises exception' do
        expect{ subject.valid? }.to raise_error(Percheron::Errors::ConfigFileInvalid, '["Config file does not exist"]')
      end
    end

    context 'when config file is valid' do
      it 'is true' do
        expect(subject.valid?).to be(true)
      end
    end
  end

  describe '#settings' do
    it 'returns a Hashie::Mash' do
      expect(subject.settings).to be_a(Hashie::Mash)
    end

    it 'has Docker configuration' do
      data = { docker: { host: "https://127.0.0.1:2376",  timeout: 10 } }
      expect(subject.settings).to include(data)
    end

     it 'has one stack' do
      data = { stacks: [ { name: "debian_jessie", containers: [ { name: "debian", version: "jessie", dockerfile: "./Dockerfile" } ] } ] }
      expect(subject.settings).to include(data)
    end
  end

  describe '#stacks' do
    it 'returns a hash of Stack objects' do
      expect(subject.stacks).to be_an(Hash)
    end

    it "has one Stack called debian_jessie'" do
      expect(subject.stacks['debian_jessie']).to be_a(Percheron::Stack)
    end
  end

end