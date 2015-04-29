require 'unit/spec_helper'

describe Percheron::Stack do
  let(:logger) { double('Logger').as_null_object }
  let(:config) { Percheron::Config.new('./spec/unit/support/.percheron_valid.yml') }

  let(:dependant_container) do
    double(
      'Perheron::Container',
      name: 'dependant_debian',
      full_name: 'debian_jessie-dependant_debian',
      dependant_container_names: [],
      dependant_containers: {},
      startable_dependant_containers: {},
      startable?: true
    )
  end

  let(:container) do
    double(
      'Perheron::Container',
      name: 'debian',
      full_name: 'debian_jessie-debian',
      dependant_container_names: %w(dependant_debian),
      dependant_containers: { 'dependant_debian' => dependant_container },
      startable_dependant_containers: { 'dependant_debian' => dependant_container },
      startable?: true
    )
  end

  let(:external_container) do
    double(
      'Perheron::Container',
      name: 'debian_external',
      full_name: 'debian_jessie-debian_external',
      dependant_container_names: [],
      dependant_containers: {},
      startable_dependant_containers: {},
      startable?: true
    )
  end

  let(:dependant_containers) { [ dependant_container ] }

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
      expect(subject.container_configs.keys.count).to eql(3)
      expect(subject.container_configs.values.collect(&:class).uniq.first).to eql(Hashie::Mash)
    end
  end

  describe '#containers' do
    it 'returns a Hash of Containers' do
      expect(subject.containers).to be_a(Hash)
    end

    context 'with no container names provided' do
      it 'is as Hash that contains two Percheron::Container objects' do
        containers = subject.containers
        expect(containers.keys.count).to eql(3)
        expect(containers.values.collect(&:class).uniq.first).to eql(Percheron::Container)
      end
    end

    context 'with container names provided' do
      it 'is as Hash that contains one Percheron::Container object' do
        containers = subject.containers([ 'debian' ])
        expect(containers.keys.count).to eql(1)
        expect(containers.values.collect(&:class).uniq.first).to eql(Percheron::Container)
      end
    end
  end

  describe 'actions' do
    before do
      allow(Percheron::Container).to receive(:new).with(subject, 'debian', config.file_base_path).and_return(container)
      allow(Percheron::Container).to receive(:new).with(subject, 'debian_external', config.file_base_path).and_return(external_container)
      allow(Percheron::Container).to receive(:new).with(subject, 'dependant_debian', config.file_base_path).and_return(dependant_container)
    end

    describe '#shell!' do
      let(:klass) { Percheron::Actions::Shell }
      let(:action_double) { double('Percheron::Actions::Shell') }

      it 'executes a shell on a given Container' do
        expect(klass).to receive(:new).with(container, command: '/bin/sh').and_return(action_double)
        expect(action_double).to receive(:execute!)
        subject.shell!('debian')
      end
    end

    describe '#logs!' do
      let(:klass) { Percheron::Actions::Logs }
      let(:action_double) { double('Percheron::Actions::Logs') }

      it 'displays the logs for a given Container' do
        expect(klass).to receive(:new).with(container, follow: false).and_return(action_double)
        expect(action_double).to receive(:execute!)
        subject.logs!('debian')
      end
    end

    describe '#stop!' do
      let(:klass) { Percheron::Actions::Stop }
      let(:action_double) { double('Percheron::Actions::Stop') }

      it 'asks each Container to stop' do
        expect(klass).to receive(:new).with(container).and_return(action_double)
        expect(klass).to receive(:new).with(external_container).and_return(action_double)
        expect(klass).to receive(:new).with(dependant_container).and_return(action_double)
        expect(action_double).to receive(:execute!).exactly(3).times
        subject.stop!
      end
    end

    describe '#start!' do
      let(:klass) { Percheron::Actions::Start }
      let(:action_double) { double('Percheron::Actions::Start') }

      it 'asks each Container to start' do
        expect(klass).to receive(:new).with(dependant_container, dependant_containers: []).and_return(action_double)
        expect(klass).to receive(:new).with(external_container, dependant_containers: []).and_return(action_double)
        expect(klass).to receive(:new).with(container, dependant_containers: dependant_containers).and_return(action_double)
        expect(action_double).to receive(:execute!).exactly(3).times
        subject.start!
      end
    end

    describe '#restart!' do
      let(:klass) { Percheron::Actions::Restart }
      let(:action_double) { double('Percheron::Actions::Restart') }

      it 'asks each Container to restart' do
        expect(klass).to receive(:new).with(dependant_container).and_return(action_double)
        expect(klass).to receive(:new).with(external_container).and_return(action_double)
        expect(klass).to receive(:new).with(container).and_return(action_double)
        expect(action_double).to receive(:execute!).exactly(3).times
        subject.restart!
      end
    end

    describe '#build!' do
      let(:klass) { Percheron::Actions::Build }
      let(:action_double) { double('Percheron::Actions::Build') }

      it 'asks each Container to build' do
        expect(klass).to receive(:new).with(dependant_container).and_return(action_double)
        expect(klass).to receive(:new).with(external_container).and_return(action_double)
        expect(klass).to receive(:new).with(container).and_return(action_double)
        expect(action_double).to receive(:execute!).exactly(3).times
        subject.build!
      end
    end

    describe '#create!' do
      let(:klass) { Percheron::Actions::Create }
      let(:action_double) { double('Percheron::Actions::Create') }

      it 'asks each Container to create' do
        expect(klass).to receive(:new).with(dependant_container, start: false).and_return(action_double)
        expect(klass).to receive(:new).with(external_container, start: false).and_return(action_double)
        expect(klass).to receive(:new).with(container, start: false).and_return(action_double)
        expect(action_double).to receive(:execute!).exactly(3).times
        subject.create!
      end
    end

    describe '#purge!' do
      let(:klass) { Percheron::Actions::Purge }
      let(:action_double) { double('Percheron::Actions::Purge') }

      it 'asks each Container to purge' do
        expect(klass).to receive(:new).with(dependant_container, force: false).and_return(action_double)
        expect(klass).to receive(:new).with(external_container, force: false).and_return(action_double)
        expect(klass).to receive(:new).with(container, force: false).and_return(action_double)
        expect(action_double).to receive(:execute!).exactly(3).times
        subject.purge!
      end
    end

    describe '#recreate!' do
      let(:klass) { Percheron::Actions::Recreate }
      let(:action_double) { double('Percheron::Actions::Recreate') }

      it 'asks each Container to recreate' do
        expect(klass).to receive(:new).with(dependant_container, start: false).and_return(action_double)
        expect(klass).to receive(:new).with(external_container, start: false).and_return(action_double)
        expect(klass).to receive(:new).with(container, start: false).and_return(action_double)
        expect(action_double).to receive(:execute!).exactly(3).times
        subject.recreate!
      end
    end
  end

  describe '#valid?' do
    it 'is true' do
      expect(subject.valid?).to be(true)
    end
  end
end
