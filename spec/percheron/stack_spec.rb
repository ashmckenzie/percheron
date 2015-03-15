require 'spec_helper'

describe Percheron::Stack do

  let(:logger) { double('Logger').as_null_object }
  let(:config) { Percheron::Config.new('./spec/support/.percheron_valid.yml') }
  let(:dependant_container) { double('Perheron::Container') }
  let(:dependant_containers) { [ dependant_container ] }
  let(:container) { double('Perheron::Container', name: 'debian', dependant_containers: { 'dependant_debian' => dependant_container }, dependant_container_names: %w{dependant_debian}) }

  subject { described_class.new(config, 'debian_jessie') }

  before do
    $logger = logger
  end

  after do
    $logger = nil
  end

  describe '.get' do
    context 'with no stack_name provided' do
      it 'returns a Hash of Stacks' do
        expect(described_class.get(config)).to be_a(Hash)
      end

      it 'has one Stack' do
        expect(described_class.get(config).keys.count).to eql(1)
      end

      it 'is the debian_jessie Stack' do
        expect(described_class.get(config).keys.first).to eql('debian_jessie')
      end
    end

    context 'with a stack_name provided' do
      context 'that does not exist' do
        it 'returns an empty Hash' do
          expect{ described_class.get(config, 'does_not_exist') }.to raise_error(Percheron::Errors::StackInvalid, 'Name is invalid')
        end
      end

      context 'that does exist' do
        it 'returns a Hash of Stacks' do
          expect(described_class.get(config, 'debian_jessie')).to be_a(Hash)
        end

        it 'has one Stack' do
          expect(described_class.get(config, 'debian_jessie').keys.count).to eql(1)
        end

        it 'is the debian_jessie Stack' do
          expect(described_class.get(config, 'debian_jessie').keys.first).to eql('debian_jessie')
        end
      end
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

  describe '#filter_containers' do
    it 'returns a Hash of Containers' do
      expect(subject.filter_containers).to be_a(Hash)
    end

    context 'with no container names provided' do
      it 'is as Hash that contains two Percheron::Container objects' do
        containers = subject.filter_containers
        expect(containers.keys.count).to eql(2)
        expect(containers.values.collect(&:class).uniq.first).to eql(Percheron::Container)
      end
    end

    context 'with container names provided' do
      it 'is as Hash that contains one Percheron::Container object' do
        containers = subject.filter_containers([ 'debian' ])
        expect(containers.keys.count).to eql(1)
        expect(containers.values.collect(&:class).uniq.first).to eql(Percheron::Container)
      end
    end
  end

  describe 'actions' do
    before do
      allow(Percheron::Container).to receive(:new).with(config, subject, 'debian').and_return(container)
      allow(Percheron::Container).to receive(:new).with(config, subject, 'dependant_debian').and_return(container)

      expect(action_double).to receive(:execute!).twice
    end

    describe '#stop!' do
      let(:klass) { Percheron::Actions::Stop }
      let(:container_names) { %w{debian dependant_debian} }
      let(:action_double) { double('Percheron::Actions::Stop') }

      it 'asks each Container to stop' do
        expect(klass).to receive(:new).with(container).and_return(action_double).twice
        subject.stop!
      end
    end

    describe '#start!' do
      let(:klass) { Percheron::Actions::Start }
      let(:container_names) { %w{dependant_debian debian} }
      let(:action_double) { double('Percheron::Actions::Start') }

      it 'asks each Container to start' do
        expect(klass).to receive(:new).with(container, dependant_containers: dependant_containers).and_return(action_double).twice
        subject.start!
      end
    end

    describe '#restart!' do
      let(:klass) { Percheron::Actions::Restart }
      let(:container_names) { %w{debian dependant_debian} }
      let(:action_double) { double('Percheron::Actions::Restart') }

      it 'asks each Container to restart' do
        expect(klass).to receive(:new).with(container).and_return(action_double).twice
        subject.restart!
      end
    end

    describe '#create!' do
      let(:klass) { Percheron::Actions::Create }
      let(:container_names) { %w{dependant_debian debian} }
      let(:action_double) { double('Percheron::Actions::Create') }

      it 'asks each Container to create' do
        expect(klass).to receive(:new).with(container).and_return(action_double).twice
        subject.create!
      end
    end

    describe '#purge!' do
      let(:klass) { Percheron::Actions::Purge }
      let(:container_names) { %w{dependant_debian debian} }
      let(:action_double) { double('Percheron::Actions::Purge') }

      it 'asks each Container to purge' do
        expect(klass).to receive(:new).with(container).and_return(action_double).twice
        subject.purge!
      end
    end

    describe '#recreate!' do
      let(:klass) { Percheron::Actions::Recreate }
      let(:container_names) { %w{dependant_debian debian} }
      let(:action_double) { double('Percheron::Actions::Recreate') }

      context 'with force_recreate not defined' do
        it 'asks each Container to recreate' do
          expect(klass).to receive(:new).with(container, force_recreate: false, delete: false).and_return(action_double).twice
          subject.recreate!
        end
      end

      context 'with delete set to true' do
        it 'asks each Container to recreate' do
          expect(klass).to receive(:new).with(container, force_recreate: false, delete: true).and_return(action_double).twice
          subject.recreate!(delete: true)
        end
      end

      context 'with force_recreate set to false' do
        it 'asks each Container to recreate' do
          expect(klass).to receive(:new).with(container, force_recreate: false, delete: false).and_return(action_double).twice
          subject.recreate!(force_recreate: false)
        end
      end

      context 'with force_recreate set to true' do
        it 'asks each Container to recreate' do
          expect(klass).to receive(:new).with(container, force_recreate: true, delete: false).and_return(action_double).twice
          subject.recreate!(force_recreate: true)
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
