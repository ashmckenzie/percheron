require 'spec_helper'

describe Percheron::Config do

  let(:config_file) { './spec/fixtures/.percheron_valid.yml' }

  subject { described_class.new(config_file) }

  describe '#settings' do
    it 'returns a Hashie::Mash' do
      expect(subject.settings).to be_a(Hashie::Mash)
    end

    it 'has Docker configuration' do
      data = { docker: { host: "https://127.0.0.1:2376",  timeout: 10 } }
      expect(subject.settings).to include(data)
    end

     it 'has one stack' do
      data = { stacks: [ { name: "debian_jessie", container_configs: [ { name: "debian", version: 1.0, dockerfile: "./Dockerfile" } ] } ] }
      expect(subject.settings).to include(data)
    end
  end

  describe '#stacks' do
    it 'returns a Hash of stack configs' do
      expect(subject.stacks).to be_a(Hash)
    end

    it 'has one stack config' do
      expect(subject.stacks.count).to eql(1)
    end
  end

  describe '#file_base_path' do
    it 'is the directory in which the file resides' do
      expect(subject.file_base_path).to eql(Pathname.new(config_file).expand_path.dirname)
    end
  end

  describe '#valid?' do
    context 'when config file is invalid' do
      let(:config_file) { './spec/fixtures/.percheron_empty.yml' }

      it 'raises exception' do
        expect{ subject.valid? }.to raise_error(Percheron::Errors::ConfigFileInvalid)
      end
    end

    context 'when config file is valid' do
      it 'is true' do
        expect(subject.valid?).to be(true)
      end
    end
  end

end
