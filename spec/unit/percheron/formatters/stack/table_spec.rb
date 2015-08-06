require 'unit/spec_helper'

describe Percheron::Formatters::Stack::Table do
  let(:config_file_name) { './spec/unit/support/.percheron_valid_table.yml' }
  let(:config) { Percheron::Config.load!(config_file_name) }
  let(:stack) { Percheron::Stack.new(config, 'debian_jessie') }

  subject { described_class.new(stack) }

  before do
    $logger = double('Logger').as_null_object
  end

  describe '#generate' do
    it 'returns a Terminal::Table' do
      expect(subject.generate).to be_a(Terminal::Table)
    end
  end
end
