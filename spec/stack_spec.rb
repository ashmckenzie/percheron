require 'spec_helper'

describe Percheron::Stack do

  let(:config) { Percheron::Config.new('./spec/fixtures/.percheron_valid.yml') }
  let(:stack_name) { 'debian_jessie' }

  subject { described_class.new(config, stack_name) }

  describe '.all' do
    it 'returns an Hash of Stacks' do
      expect(described_class.all(config)).to be_a(Hash)
    end
  end

  describe '#valid?' do
    context 'when stack name is valid' do
      it 'is true' do
        expect(subject.valid?).to be(true)
      end
    end
  end

  describe '#container_configs' do
    it 'returns a Hash of ContainerConfigs' do
      expect(subject.container_configs).to be_a(Hash)
    end
  end

end
