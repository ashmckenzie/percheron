require 'spec_helper'

describe Percheron::Validators::Config do

  let(:config_file_name) { './spec/fixtures/.percheron_valid.yml' }
  let(:config_file) { Pathname.new(config_file_name).expand_path }

  subject { described_class.new(config_file) }

  describe '#valid?' do
    context 'when config file is missing' do
      let(:config_file_name) { './spec/fixtures/missing.yml' }

      it 'raises exception' do
        expect{ subject.valid? }.to raise_error(Percheron::Errors::ConfigFileInvalid, 'Config file does not exist')
      end
    end

    context 'when config file is empty' do
      let(:config_file_name) { './spec/fixtures/.percheron_empty.yml' }

      it 'raises exception' do
        expect{ subject.valid? }.to raise_error(Percheron::Errors::ConfigFileInvalid, 'Config file is empty')
      end
    end

    context 'when config file is invalid' do
      let(:config_file_name) { './spec/fixtures/.percheron_invalid_docker.yml' }

      it 'raises exception' do
        expect{ subject.valid? }.to raise_error(Percheron::Errors::ConfigFileInvalid, 'Config file is invalid')
      end
    end

    context 'when config file is valid' do
      it 'is true' do
        expect(subject.valid?).to be(true)
      end
    end
  end

end
