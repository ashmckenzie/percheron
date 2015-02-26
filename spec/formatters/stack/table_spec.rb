require 'spec_helper'

describe Percheron::Formatters::Stack::Table do

  let(:config_file_name) { './spec/fixtures/.percheron_valid.yml' }
  let(:config) { Percheron::Config.new(config_file_name) }
  let(:stack) { Percheron::Stack.new(config, config.settings.stacks.first) }

  subject { described_class.new(stack) }

  describe '#generate' do
    it 'returns a Terminal::Table' do
      expect(subject.generate).to be_a(Terminal::Table)
    end
  end

end
