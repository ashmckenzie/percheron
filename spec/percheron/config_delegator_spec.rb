require 'spec_helper'

describe Percheron::ConfigDelegator do
  let(:config) { {} }
  let(:test_class) do
    Class.new do
      extend Percheron::ConfigDelegator

      def_config_item_with_default :config, 'blah', :key1, :test2

      def initialize(config)
        @config = config
      end

      private

        attr_reader :config
    end
  end

  subject { test_class.new(config) }

  describe '#key1' do
    context 'when config is not defined' do
      it 'returns the default' do
        expect(subject.key1).to eql('blah')
      end
    end

    context 'when config is defined' do
      let(:config) { { key1: 'value1' } }

      it 'returns the correct value' do
        expect(subject.key1).to eql('value1')
      end
    end
  end
end
