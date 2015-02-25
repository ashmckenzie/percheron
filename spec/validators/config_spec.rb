require 'spec_helper'

describe Percheron::Validators::Config do

  let(:config_file) { '' }

  subject { described_class.new(config_file) }

  describe '#valid?' do
    context 'when config is invalid' do
      let(:config_file) { Pathname.new('./spec/fixtures/missing.yml') }

      it 'raises exception' do
        expect{ subject.valid? }.to raise_error(Percheron::Errors::ConfigFileInvalid, '["Config file does not exist"]')
      end
    end

    context 'when config is valid' do
      let(:config_file) { Pathname.new('./spec/fixtures/.percheron.yml') }

      it 'is true' do
        expect(subject.valid?).to be(true)
      end
    end
  end

end
