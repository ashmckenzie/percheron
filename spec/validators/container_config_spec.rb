require 'spec_helper'

describe Percheron::Validators::ContainerConfig do

  let(:config) { {} }
  let(:container_config) { Percheron::ContainerConfig.new(Hashie::Mash.new(config)) }

  subject { described_class.new(container_config) }

  describe '#valid?' do
    context 'when container config is invalid' do
      let(:config) { {} }

      it 'is false' do
        expect{ subject.valid? }.to raise_error(Percheron::Errors::ContainerConfigInvalid, '["Name is invalid", "Version is invalid", "Dockerfile is invalid"]')
      end
    end

    context 'when container config is valid' do
      let(:config) { { name: 'container1', version: 'latest', dockerfile: './spec/fixtures/Dockerfile' } }

      it 'is true' do
        expect(subject.valid?).to be(true)
      end
    end
  end

end
