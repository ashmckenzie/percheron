require 'spec_helper'

describe Percheron::Validators::Stack do

  let(:config) { {} }
  let(:stack) { Percheron::Stack.new(Hashie::Mash.new(config)) }

  subject { described_class.new(stack) }

  describe '#valid?' do
    context 'when stack is invalid' do
      let(:config) { {} }

      it 'raises exception' do
        expect{ subject.valid? }.to raise_error(Percheron::Errors::StackInvalid, '["Name is invalid"]')
      end
    end

    context 'when stack is valid' do
      let(:config) { { name: 'stack1', containers: [ ] } }

      it 'is true' do
        expect(subject.valid?).to be(true)
      end
    end
  end

end
