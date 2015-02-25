require 'spec_helper'

describe Percheron::Stack do

  let(:stack_config) do
    {
      name: 'stack1',
      containers: [ ]
    }
  end

  subject { described_class.new(Hashie::Mash.new(stack_config)) }

  describe '#valid?' do
    context 'when config is invalid' do
      let(:stack_config) { {} }

      it 'raises exception' do
        expect{ subject.valid? }.to raise_error(Percheron::Errors::StackInvalid, '["Name is invalid"]')
      end
    end

    context 'when config is valid' do
      it 'is true' do
        expect(subject.valid?).to be(true)
      end
    end
  end


end
