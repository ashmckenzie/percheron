require 'spec_helper'

describe Percheron::Stack do

  let(:config) { Percheron::Config.new('./spec/fixtures/.percheron_valid.yml') }
  let(:stack_name) { 'debian_jessie' }

  let(:container_double) { double('Perheron::Container') }
  let(:containers) { { 'container_double' => container_double } }

  subject { described_class.new(config, stack_name) }

  describe '.all' do
    it 'returns an Hash of Stacks' do
      expect(described_class.all(config)).to be_a(Hash)
    end
  end

  describe '#container_configs' do
    it 'returns a Hash of Container objects' do
      expect(subject.container_configs).to be_a(Hash)
    end

    it 'is as Hash that contains two Hashie::Mash objects' do
      expect(subject.container_configs.keys.count).to eql(2)
      expect(subject.container_configs.values.collect(&:class).uniq.first).to eql(Hashie::Mash)
    end
  end

  describe '#containers' do
    it 'returns a Hash of Containers' do
      expect(subject.containers).to be_a(Hash)
    end

    it 'is as Hash that contains two Percheron::Container::Main objects' do
      expect(subject.containers.keys.count).to eql(2)
      expect(subject.containers.values.collect(&:class).uniq.first).to eql(Percheron::Container::Main)
    end
  end

  describe 'actions' do
    before do
      expect(subject).to receive(:containers).and_return(containers)
    end

    describe '#stop!' do
      it 'asks each Container to stop!' do
        expect(container_double).to receive(:stop!)
        subject.stop!
      end
    end

    describe '#start!' do
      it 'asks each Container to start!' do
        expect(container_double).to receive(:start!)
        subject.start!
      end
    end

    describe '#restart!' do
      it 'asks each Container to restart!' do
        expect(container_double).to receive(:restart!)
        subject.restart!
      end
    end

    describe '#create!' do
      it 'asks each Container to create!' do
        expect(container_double).to receive(:create!)
        subject.create!
      end
    end

    describe '#recreate!' do
      before do
        expect(container_double).to receive(:recreate!).with(bypass_auto_recreate: expected_bypass_auto_recreate)
      end

      context 'with bypass_auto_recreate not defined' do
        let (:expected_bypass_auto_recreate) { false }

        it 'asks each Container to recreate!' do
          subject.recreate!
        end
      end

      context 'with bypass_auto_recreate set to false' do
        let (:expected_bypass_auto_recreate) { false }

        it 'asks each Container to recreate!' do
          subject.recreate!(bypass_auto_recreate: false)
        end
      end

      context 'with bypass_auto_recreate set to true' do
        let (:expected_bypass_auto_recreate) { true }

        it 'asks each Container to recreate!' do
          subject.recreate!(bypass_auto_recreate: true)
        end
      end
    end
  end

  describe '#valid?' do
    it 'is true' do
      expect(subject.valid?).to be(true)
    end
  end

end
