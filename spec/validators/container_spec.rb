require 'spec_helper'

describe Percheron::Validators::Container do

  let(:config) { Percheron::Config.new('./spec/fixtures/.percheron_valid.yml') }
  let(:stack) { Percheron::Stack.new(config, 'debian_jessie') }
  let(:container_name) { 'debian' }
  let(:container) { Percheron::Container.new(config, stack, container_name) }

  subject { described_class.new(container) }

  describe '#valid?' do
    context 'when container config is missing name' do
      let(:config) { Percheron::Config.new('./spec/fixtures/.percheron_missing_name.yml') }
      it 'raises exception' do
        expect{ subject.valid? }.to raise_error(Percheron::Errors::ContainerInvalid, 'Name is invalid')
      end
    end

    context 'when container config is missing version' do
      let(:config) { Percheron::Config.new('./spec/fixtures/.percheron_missing_version.yml') }
      it 'raises exception' do
        expect{ subject.valid? }.to raise_error(Percheron::Errors::ContainerInvalid, 'Version is invalid')
      end
    end

    context 'when container config is missing dockerfile' do
      let(:config) { Percheron::Config.new('./spec/fixtures/.percheron_missing_dockerfile.yml') }
      it 'raises exception' do
        expect{ subject.valid? }.to raise_error(Percheron::Errors::ContainerInvalid, 'Dockerfile is invalid')
      end
    end

    context 'when container config is valid' do
      it 'is true' do
        expect(subject.valid?).to be(true)
      end
    end
  end

end
