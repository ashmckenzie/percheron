require 'spec_helper'

describe Percheron::Validators::Stack do

  let(:config_file_name) { './spec/fixtures/.percheron_valid.yml' }
  let(:config) { Percheron::Config.new(config_file_name) }
  let(:stack) { Percheron::Stack.new(config, config.settings.stacks.first) }

  subject { described_class.new(stack) }

  describe '#valid?' do
    context 'when stack is invalid' do
      let(:config_file_name) { './spec/fixtures/.percheron_invalid_stacks.yml' }

      it 'raises exception' do
        expect{ subject.valid? }.to raise_error(Percheron::Errors::StackInvalid, 'Name is invalid')
      end
    end

    context 'when stack is valid' do
      it 'is true' do
        expect(subject.valid?).to be(true)
      end
    end
  end

end
