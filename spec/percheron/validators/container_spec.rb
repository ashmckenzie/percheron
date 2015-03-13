require 'spec_helper'

describe Percheron::Validators::Container do

  let(:config) { Percheron::Config.new('./spec/support/.percheron_valid.yml') }
  let(:stack) { Percheron::Stack.new(config, 'debian_jessie') }
  let(:container) { Percheron::Container.new(config, stack, 'debian') }

  subject { described_class.new(container) }

  describe '#valid?' do
    context 'when container config is missing name' do
      let(:config) { Percheron::Config.new('./spec/support/.percheron_missing_name.yml') }
      it 'raises exception' do
        expect{ subject.valid? }.to raise_error(Percheron::Errors::ContainerInvalid, "Container config is invalid: Name is invalid")
      end
    end

    context 'when container config is missing version' do
      let(:config) { Percheron::Config.new('./spec/support/.percheron_missing_version.yml') }
      it 'raises exception' do
        expect{ subject.valid? }.to raise_error(Percheron::Errors::ContainerInvalid, "Container config for 'debian' is invalid: Version is invalid")
      end
    end

    context 'when container config contains an invalid version' do
      let(:config) { Percheron::Config.new('./spec/support/.percheron_invalid_version.yml') }
      it 'raises exception' do
        expect{ subject.valid? }.to raise_error(Percheron::Errors::ContainerInvalid, "Container config for 'debian' is invalid: Version is invalid")
      end
    end

    context 'when container config is missing dockerfile' do
      let(:config) { Percheron::Config.new('./spec/support/.percheron_missing_dockerfile.yml') }
      it 'raises exception' do
        expect{ subject.valid? }.to raise_error(Percheron::Errors::ContainerInvalid, "Container config for 'debian' is invalid: Dockerfile is invalid")
      end
    end

    context 'when container config is valid' do
      it 'is true' do
        expect(subject.valid?).to be(true)
      end
    end
  end

end
