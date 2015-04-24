require 'unit/spec_helper'

describe Percheron::Validators::Config do
  subject { described_class.new(config_file) }

  describe '#valid?' do
    context 'when config file is not defined' do
      let(:config_file) { nil }

      it 'raises exception' do
        expect { subject.valid? }.to raise_error(Percheron::Errors::ConfigFileInvalid, 'Config is invalid: Is not defined')
      end
    end

    context 'when config file is defined' do
      let(:config_file_name) { './spec/unit/support/.percheron_valid.yml' }
      let(:config_file) { Pathname.new(config_file_name).expand_path }

      context 'and does not exist on disk' do
        let(:config_file_name) { './spec/unit/support/.percheron_missing.yml' }

        it 'raises exception' do
          expect { subject.valid? }.to raise_error(Percheron::Errors::ConfigFileInvalid, 'Config is invalid: Does not exist')
        end
      end

      context 'and is empty' do
        let(:config_file_name) { './spec/unit/support/.percheron_empty.yml' }

        it 'raises exception' do
          expect { subject.valid? }.to raise_error(Percheron::Errors::ConfigFileInvalid, 'Config is invalid: Is empty')
        end
      end

      context 'and is invalid' do
        let(:config_file_name) { './spec/unit/support/.percheron_invalid_docker.yml' }

        it 'raises exception' do
          expect { subject.valid? }.to raise_error(Percheron::Errors::ConfigFileInvalid, 'Config is invalid: Is invalid')
        end
      end

      context 'and is valid' do
        it 'is true' do
          expect(subject.valid?).to be(true)
        end
      end
    end
  end
end
