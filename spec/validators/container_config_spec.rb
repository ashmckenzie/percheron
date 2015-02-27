require 'spec_helper'

describe Percheron::Validators::ContainerConfig do

  let(:config) { Percheron::Config.new('./spec/fixtures/.percheron_valid.yml') }
  let(:container_config) { Percheron::ContainerConfig.new(config, container_config_config) }

  subject { described_class.new(container_config) }

  describe '#valid?' do
    context 'when container config is missing name' do
      let(:container_config_config) { {} }

      it 'raises exception' do
        expect{ subject.valid? }.to raise_error(Percheron::Errors::ContainerConfigInvalid, 'Name is invalid')
      end
    end

    context 'when container config is missing version' do
      let(:container_config_config) { { name: 'debian' } }

      it 'raises exception' do
        expect{ subject.valid? }.to raise_error(Percheron::Errors::ContainerConfigInvalid, 'Version is invalid')
      end
    end

    context 'when container config is missing dockerfile' do
      let(:container_config_config) { { name: 'debian', version: 'latest' } }

      it 'raises exception' do
        expect{ subject.valid? }.to raise_error(Percheron::Errors::ContainerConfigInvalid, 'Dockerfile is invalid')
      end
    end

    context 'when container config is valid' do
      let(:container_config_config) { config.stack_configs.first[1].container_configs.first }

      it 'is true' do
        expect(subject.valid?).to be(true)
      end
    end
  end

end
