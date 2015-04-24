require 'unit/spec_helper'

describe Percheron::Validators::Container do
  let(:config) { Percheron::Config.new('./spec/unit/support/.percheron_valid.yml') }
  let(:stack) { Percheron::Stack.new(config, 'debian_jessie') }
  let(:container) { Percheron::Container.new(stack, 'debian', config.file_base_path) }

  subject { described_class.new(container) }

  describe '#valid?' do
    context 'when container config is missing name' do
      let(:config) { Percheron::Config.new('./spec/unit/support/.percheron_missing_name.yml') }
      it 'raises exception' do
        expect { subject.valid? }.to raise_error(Percheron::Errors::ContainerInvalid, 'Container config is invalid: Name is invalid')
      end
    end

    context 'when container config is missing version' do
      let(:config) { Percheron::Config.new('./spec/unit/support/.percheron_missing_version.yml') }
      it 'raises exception' do
        expect { subject.valid? }.to raise_error(Percheron::Errors::ContainerInvalid, "Container config for 'debian' is invalid: Version is invalid")
      end
    end

    context 'when container config is missing dockerfile AND image_name' do
      let(:config) { Percheron::Config.new('./spec/unit/support/.percheron_missing_dockerfile_and_image_name.yml') }
      it 'raises exception' do
        expect { subject.valid? }.to raise_error(Percheron::Errors::ContainerInvalid, "Container config for 'debian' is invalid: Dockerfile OR image name not provided")
      end
    end

    context 'when container config is has an invalid dockerfile' do
      let(:config) { Percheron::Config.new('./spec/unit/support/.percheron_invalid_dockerfile.yml') }
      it 'raises exception' do
        expect { subject.valid? }.to raise_error(Percheron::Errors::ContainerInvalid, "Container config for 'debian' is invalid: Dockerfile is invalid")
      end
    end

    context 'when container config has an invalid Docker image' do
      let(:config) { Percheron::Config.new('./spec/unit/support/.percheron_invalid_docker_image.yml') }
      it 'raises exception' do
        expect { subject.valid? }.to raise_error(Percheron::Errors::ContainerInvalid, "Container config for 'debian' is invalid: Docker image is invalid")
      end
    end

    context 'when container config is valid' do
      it 'is true' do
        expect(subject.valid?).to be(true)
      end
    end
  end
end
