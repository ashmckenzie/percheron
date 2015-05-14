require 'unit/spec_helper'

describe Percheron::Validators::Unit do
  let(:config) { Percheron::Config.new('./spec/unit/support/.percheron_valid.yml') }
  let(:stack) { Percheron::Stack.new(config, 'debian_jessie') }
  let(:unit) { Percheron::Unit.new(config, stack, 'debian') }

  subject { described_class.new(unit) }

  describe '#valid?' do
    context 'when unit config is missing name' do
      let(:config) { Percheron::Config.new('./spec/unit/support/.percheron_missing_name.yml') }
      it 'raises exception' do
        expect { subject.valid? }.to raise_error(Percheron::Errors::UnitInvalid, 'Container config is invalid: Name is invalid')
      end
    end

    context 'when unit config is missing version' do
      let(:config) { Percheron::Config.new('./spec/unit/support/.percheron_missing_version.yml') }
      it 'raises exception' do
        expect { subject.valid? }.to raise_error(Percheron::Errors::UnitInvalid, "Container config for 'debian' is invalid: Version is invalid")
      end
    end

    context 'when unit config is missing dockerfile AND image_name' do
      let(:config) { Percheron::Config.new('./spec/unit/support/.percheron_missing_dockerfile_and_image_name.yml') }
      it 'raises exception' do
        expect { subject.valid? }.to raise_error(Percheron::Errors::UnitInvalid, "Container config for 'debian' is invalid: Dockerfile OR image name not provided")
      end
    end

    context 'when unit config is has an invalid dockerfile' do
      let(:config) { Percheron::Config.new('./spec/unit/support/.percheron_invalid_dockerfile.yml') }
      it 'raises exception' do
        expect { subject.valid? }.to raise_error(Percheron::Errors::UnitInvalid, "Container config for 'debian' is invalid: Dockerfile is invalid")
      end
    end

    context 'when unit config has an invalid Docker image' do
      let(:config) { Percheron::Config.new('./spec/unit/support/.percheron_invalid_docker_image.yml') }
      it 'raises exception' do
        expect { subject.valid? }.to raise_error(Percheron::Errors::UnitInvalid, "Container config for 'debian' is invalid: Docker image is invalid")
      end
    end

    context 'when unit config is valid' do
      it 'is true' do
        expect(subject.valid?).to be(true)
      end
    end
  end
end
