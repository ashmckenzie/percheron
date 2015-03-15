require 'spec_helper'

describe Percheron::Config do
  let(:config_file) { './spec/support/.percheron_valid.yml' }

  subject { described_class.new(config_file) }

  describe '#stacks' do
    it 'returns a Hash of stack configs' do
      expect(subject.stacks).to be_a(Hash)
    end

    it 'has one stack config' do
      expect(subject.stacks.count).to eql(1)
    end
  end

  describe '#file_base_path' do
    it 'is the directory in which the file resides' do
      expect(subject.file_base_path).to eql(Pathname.new(config_file).expand_path.dirname)
    end
  end

  describe '#valid?' do
    it 'is true' do
      expect(subject.valid?).to be(true)
    end
  end
end
