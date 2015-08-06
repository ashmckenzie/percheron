require 'unit/spec_helper'

describe Percheron::Stack do
  let(:logger) { double('Logger').as_null_object }
  let(:config) { Percheron::Config.load!('./spec/unit/support/.percheron_valid.yml') }

  let(:dependant_unit) do
    double(
      'Perheron::Unit',
      name: 'dependant_debian',
      full_name: 'debian_jessie-dependant_debian',
      display_name: 'debian_jessie:dependant_debian',
      dependant_unit_names: [],
      dependant_units: {},
      startable_dependant_units: {},
      startable?: true
    )
  end

  let(:unit) do
    double(
      'Perheron::Unit',
      name: 'debian',
      full_name: 'debian_jessie-debian',
      display_name: 'debian_jessie:debian',
      dependant_unit_names: %w(dependant_debian),
      dependant_units: { 'dependant_debian' => dependant_unit },
      startable_dependant_units: { 'dependant_debian' => dependant_unit },
      startable?: true
    )
  end

  let(:external_unit) do
    double(
      'Perheron::Unit',
      name: 'debian_external',
      full_name: 'debian_jessie-debian_external',
      display_name: 'debian_jessie:debian_external',
      dependant_unit_names: [],
      dependant_units: {},
      startable_dependant_units: {},
      startable?: true
    )
  end

  let(:pseudo1_unit) do
    double(
      'Perheron::Unit',
      name: 'debian_pseudo1',
      full_name: 'debian_jessie-xxx',
      display_name: 'debian_jessie:xxx',
      dependant_unit_names: [],
      dependant_units: {},
      startable_dependant_units: {},
      startable?: true
    )
  end

  let(:pseudo2_unit) do
    double(
      'Perheron::Unit',
      name: 'debian_pseudo2',
      full_name: 'debian_jessie-xxx',
      display_name: 'debian_jessie:xxx',
      dependant_unit_names: [],
      dependant_units: {},
      startable_dependant_units: {},
      startable?: true
    )
  end

  let(:dependant_units) { [ dependant_unit ] }

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

  describe '#metastore_key' do
    it "returns the stacks' key when using metascore" do
      expect(subject.metastore_key).to eql('stacks.debian_jessie')
    end
  end

  describe '#unit_configs' do
    it 'returns a Hash of Container objects' do
      expect(subject.unit_configs).to be_a(Hash)
    end

    it 'is as Hash that contains two Hashie::Mash objects' do
      expect(subject.unit_configs.keys.count).to eql(5)
      expect(subject.unit_configs.values.collect(&:class).uniq.first).to eql(Hashie::Mash)
    end
  end

  describe '#units' do
    it 'returns a Hash of Containers' do
      expect(subject.units).to be_a(Hash)
    end

    context 'with no unit names provided' do
      it 'is as Hash that contains two Percheron::Unit objects' do
        units = subject.units
        expect(units.keys.count).to eql(5)
        expect(units.values.collect(&:class).uniq.first).to eql(Percheron::Unit)
      end
    end

    context 'with unit names provided' do
      it 'is as Hash that contains one Percheron::Unit object' do
        units = subject.units([ 'debian' ])
        expect(units.keys.count).to eql(1)
        expect(units.values.collect(&:class).uniq.first).to eql(Percheron::Unit)
      end
    end
  end

  describe 'actions' do
    before do
      allow(Percheron::Unit).to receive(:new).with(config, subject, 'debian').and_return(unit)
      allow(Percheron::Unit).to receive(:new).with(config, subject, 'debian_external').and_return(external_unit)
      allow(Percheron::Unit).to receive(:new).with(config, subject, 'dependant_debian').and_return(dependant_unit)
      allow(Percheron::Unit).to receive(:new).with(config, subject, 'debian_pseudo1').and_return(pseudo1_unit)
      allow(Percheron::Unit).to receive(:new).with(config, subject, 'debian_pseudo2').and_return(pseudo2_unit)
    end

    describe '#graph!' do
      let(:file) { '/tmp/stack.png' }
      let(:graph) { double('Percheron::Graph') }

      it 'calls out to create a dependancy graph' do
        expect(Percheron::Graph).to receive(:new).with(subject).and_return(graph)
        expect(graph).to receive(:save!).with(file)
        subject.graph!(file)
      end
    end

    describe '#shell!' do
      let(:klass) { Percheron::Actions::Shell }
      let(:action_double) { double('Percheron::Actions::Shell') }

      it 'executes a shell on a given Container' do
        expect(klass).to receive(:new).with(unit, command: '/bin/sh').and_return(action_double)
        expect(action_double).to receive(:execute!)
        subject.shell!('debian')
      end
    end

    describe '#logs!' do
      let(:klass) { Percheron::Actions::Logs }
      let(:action_double) { double('Percheron::Actions::Logs') }

      it 'displays the logs for a given Container' do
        expect(klass).to receive(:new).with(unit, follow: false).and_return(action_double)
        expect(action_double).to receive(:execute!)
        subject.logs!('debian')
      end
    end

    describe '#stop!' do
      let(:klass) { Percheron::Actions::Stop }
      let(:action_double) { double('Percheron::Actions::Stop') }

      it 'asks each Container to stop' do
        expect(klass).to receive(:new).with(unit).and_return(action_double)
        expect(klass).to receive(:new).with(external_unit).and_return(action_double)
        expect(klass).to receive(:new).with(dependant_unit).and_return(action_double)
        expect(klass).to receive(:new).with(pseudo1_unit).and_return(action_double)
        expect(klass).to receive(:new).with(pseudo2_unit).and_return(action_double)
        expect(action_double).to receive(:execute!).exactly(5).times
        subject.stop!
      end
    end

    describe '#start!' do
      let(:klass) { Percheron::Actions::Start }
      let(:action_double) { double('Percheron::Actions::Start') }

      it 'asks each Container to start' do
        expect(klass).to receive(:new).with(pseudo2_unit, dependant_units: []).and_return(action_double)
        expect(klass).to receive(:new).with(pseudo1_unit, dependant_units: []).and_return(action_double)
        expect(klass).to receive(:new).with(dependant_unit, dependant_units: []).and_return(action_double)
        expect(klass).to receive(:new).with(external_unit, dependant_units: []).and_return(action_double)
        expect(klass).to receive(:new).with(unit, dependant_units: dependant_units).and_return(action_double)
        expect(action_double).to receive(:execute!).exactly(5).times
        subject.start!
      end
    end

    describe '#restart!' do
      let(:klass) { Percheron::Actions::Restart }
      let(:action_double) { double('Percheron::Actions::Restart') }

      it 'asks each Container to restart' do
        expect(klass).to receive(:new).with(pseudo2_unit).and_return(action_double)
        expect(klass).to receive(:new).with(pseudo1_unit).and_return(action_double)
        expect(klass).to receive(:new).with(dependant_unit).and_return(action_double)
        expect(klass).to receive(:new).with(external_unit).and_return(action_double)
        expect(klass).to receive(:new).with(unit).and_return(action_double)
        expect(action_double).to receive(:execute!).exactly(5).times
        subject.restart!
      end
    end

    describe '#build!' do
      let(:klass) { Percheron::Actions::Build }
      let(:action_double) { double('Percheron::Actions::Build') }

      it 'asks each Container to build' do
        expect(klass).to receive(:new).with(pseudo2_unit, forcerm: false).and_return(action_double)
        expect(klass).to receive(:new).with(pseudo1_unit, forcerm: false).and_return(action_double)
        expect(klass).to receive(:new).with(dependant_unit, forcerm: false).and_return(action_double)
        expect(klass).to receive(:new).with(external_unit, forcerm: false).and_return(action_double)
        expect(klass).to receive(:new).with(unit, forcerm: false).and_return(action_double)
        expect(action_double).to receive(:execute!).exactly(5).times
        subject.build!
      end
    end

    describe '#create!' do
      let(:klass) { Percheron::Actions::Create }
      let(:action_double) { double('Percheron::Actions::Create') }

      it 'asks each Container to create' do
        expect(klass).to receive(:new).with(pseudo2_unit, start: false).and_return(action_double)
        expect(klass).to receive(:new).with(pseudo1_unit, start: false).and_return(action_double)
        expect(klass).to receive(:new).with(dependant_unit, start: false).and_return(action_double)
        expect(klass).to receive(:new).with(external_unit, start: false).and_return(action_double)
        expect(klass).to receive(:new).with(unit, start: false).and_return(action_double)
        expect(action_double).to receive(:execute!).exactly(5).times
        subject.create!
      end
    end

    describe '#purge!' do
      let(:klass) { Percheron::Actions::Purge }
      let(:action_double) { double('Percheron::Actions::Purge') }

      it 'asks each Container to purge' do
        expect(klass).to receive(:new).with(pseudo2_unit, force: false).and_return(action_double)
        expect(klass).to receive(:new).with(pseudo1_unit, force: false).and_return(action_double)
        expect(klass).to receive(:new).with(dependant_unit, force: false).and_return(action_double)
        expect(klass).to receive(:new).with(external_unit, force: false).and_return(action_double)
        expect(klass).to receive(:new).with(unit, force: false).and_return(action_double)
        expect(action_double).to receive(:execute!).exactly(5).times
        subject.purge!
      end
    end

    describe '#recreate!' do
      let(:klass) { Percheron::Actions::Recreate }
      let(:action_double) { double('Percheron::Actions::Recreate') }

      it 'asks each Container to recreate' do
        expect(klass).to receive(:new).with(pseudo2_unit, start: false, force: false).and_return(action_double)
        expect(klass).to receive(:new).with(pseudo1_unit, start: false, force: false).and_return(action_double)
        expect(klass).to receive(:new).with(dependant_unit, start: false, force: false).and_return(action_double)
        expect(klass).to receive(:new).with(external_unit, start: false, force: false).and_return(action_double)
        expect(klass).to receive(:new).with(unit, start: false, force: false).and_return(action_double)
        expect(action_double).to receive(:execute!).exactly(5).times
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
