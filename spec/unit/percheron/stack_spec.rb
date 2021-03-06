require 'unit/spec_helper'

describe Percheron::Stack do
  let(:logger) { double('Logger').as_null_object }
  let(:config) { Percheron::Config.load!('./spec/unit/support/.percheron_valid.yml') }

  let(:needed_unit) do
    double(
      'Perheron::Unit',
      name: 'needed_debian',
      full_name: 'debian_jessie-needed_debian',
      display_name: 'debian_jessie:needed_debian',
      needed_unit_names: [],
      needed_units: {},
      startable_needed_units: {},
      startable?: true
    )
  end

  let(:unit) do
    double(
      'Perheron::Unit',
      name: 'debian',
      full_name: 'debian_jessie-debian',
      display_name: 'debian_jessie:debian',
      needed_unit_names: %w(needed_debian),
      needed_units: { 'needed_debian' => needed_unit },
      startable_needed_units: { 'needed_debian' => needed_unit },
      startable?: true
    )
  end

  let(:external_unit) do
    double(
      'Perheron::Unit',
      name: 'debian_external',
      full_name: 'debian_jessie-debian_external',
      display_name: 'debian_jessie:debian_external',
      needed_unit_names: [],
      needed_units: {},
      startable_needed_units: {},
      startable?: true
    )
  end

  let(:pseudo1_unit) do
    double(
      'Perheron::Unit',
      name: 'debian_pseudo1',
      full_name: 'debian_jessie-xxx',
      display_name: 'debian_jessie:xxx',
      needed_unit_names: [],
      needed_units: {},
      startable_needed_units: {},
      startable?: true
    )
  end

  let(:pseudo2_unit) do
    double(
      'Perheron::Unit',
      name: 'debian_pseudo2',
      full_name: 'debian_jessie-xxx',
      display_name: 'debian_jessie:xxx',
      needed_unit_names: [],
      needed_units: {},
      startable_needed_units: {},
      startable?: true
    )
  end

  let(:needed_units) { [ needed_unit ] }

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
    it 'returns a Hash of Unit objects' do
      expect(subject.unit_configs).to be_a(Hash)
    end

    it 'is as Hash that contains two Hashie::Mash objects' do
      expect(subject.unit_configs.keys.count).to eql(5)
      expect(subject.unit_configs.values.collect(&:class).uniq.first).to eql(Hashie::Mash)
    end
  end

  describe '#units' do
    it 'returns a Hash of Units' do
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
      allow(Percheron::Unit).to receive(:new).with(config, subject, 'needed_debian').and_return(needed_unit)
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

      it 'executes a shell on a given Unit' do
        expect(klass).to receive(:new).with(unit, raw_command: '/bin/sh').and_return(action_double)
        expect(action_double).to receive(:execute!)
        subject.shell!('debian')
      end
    end

    describe '#logs!' do
      let(:klass) { Percheron::Actions::Logs }
      let(:action_double) { double('Percheron::Actions::Logs') }

      it 'displays the logs for a given Unit' do
        expect(klass).to receive(:new).with(unit, follow: false).and_return(action_double)
        expect(action_double).to receive(:execute!)
        subject.logs!('debian')
      end
    end

    describe '#stop!' do
      let(:klass) { Percheron::Actions::Stop }
      let(:action_double) { double('Percheron::Actions::Stop') }

      it 'asks each Unit to stop' do
        expect(klass).to receive(:new).with(unit).and_return(action_double)
        expect(klass).to receive(:new).with(external_unit).and_return(action_double)
        expect(klass).to receive(:new).with(needed_unit).and_return(action_double)
        expect(klass).to receive(:new).with(pseudo1_unit).and_return(action_double)
        expect(klass).to receive(:new).with(pseudo2_unit).and_return(action_double)
        expect(action_double).to receive(:execute!).exactly(5).times
        subject.stop!
      end
    end

    describe '#start!' do
      let(:klass) { Percheron::Actions::Start }
      let(:action_double) { double('Percheron::Actions::Start') }

      it 'asks each Unit to start' do
        expect(klass).to receive(:new).with(pseudo2_unit, needed_units: []).and_return(action_double)
        expect(klass).to receive(:new).with(pseudo1_unit, needed_units: []).and_return(action_double)
        expect(klass).to receive(:new).with(needed_unit, needed_units: []).and_return(action_double)
        expect(klass).to receive(:new).with(external_unit, needed_units: []).and_return(action_double)
        expect(klass).to receive(:new).with(unit, needed_units: needed_units).and_return(action_double)
        expect(action_double).to receive(:execute!).exactly(5).times
        subject.start!
      end
    end

    describe '#restart!' do
      let(:klass) { Percheron::Actions::Restart }
      let(:action_double) { double('Percheron::Actions::Restart') }

      it 'asks each Unit to restart' do
        expect(klass).to receive(:new).with(pseudo2_unit).and_return(action_double)
        expect(klass).to receive(:new).with(pseudo1_unit).and_return(action_double)
        expect(klass).to receive(:new).with(needed_unit).and_return(action_double)
        expect(klass).to receive(:new).with(external_unit).and_return(action_double)
        expect(klass).to receive(:new).with(unit).and_return(action_double)
        expect(action_double).to receive(:execute!).exactly(5).times
        subject.restart!
      end
    end

    describe '#build!' do
      let(:klass) { Percheron::Actions::Build }
      let(:action_double) { double('Percheron::Actions::Build') }

      it 'asks each Unit to build' do
        expect(klass).to receive(:new).with(pseudo2_unit, usecache: true, forcerm: false).and_return(action_double)
        expect(klass).to receive(:new).with(pseudo1_unit, usecache: true, forcerm: false).and_return(action_double)
        expect(klass).to receive(:new).with(needed_unit, usecache: true, forcerm: false).and_return(action_double)
        expect(klass).to receive(:new).with(external_unit, usecache: true, forcerm: false).and_return(action_double)
        expect(klass).to receive(:new).with(unit, usecache: true, forcerm: false).and_return(action_double)
        expect(action_double).to receive(:execute!).exactly(5).times
        subject.build!
      end
    end

    describe '#create!' do
      let(:klass) { Percheron::Actions::Create }
      let(:action_double) { double('Percheron::Actions::Create') }

      it 'asks each Unit to create' do
        expected_opts = { build: true, start: false, force: false }
        expect(klass).to receive(:new).with(pseudo2_unit, expected_opts).and_return(action_double)
        expect(klass).to receive(:new).with(pseudo1_unit, expected_opts).and_return(action_double)
        expect(klass).to receive(:new).with(needed_unit, expected_opts).and_return(action_double)
        expect(klass).to receive(:new).with(external_unit, expected_opts).and_return(action_double)
        expect(klass).to receive(:new).with(unit, expected_opts).and_return(action_double)
        expect(action_double).to receive(:execute!).exactly(5).times
        subject.create!
      end

      it "asks each Unit and it's needed units to create" do
        expected_opts = { build: true, start: false, force: false }
        expect(klass).to receive(:new).with(pseudo2_unit, expected_opts).and_return(action_double)
        expect(klass).to receive(:new).with(pseudo1_unit, expected_opts).and_return(action_double)
        expect(klass).to receive(:new).with(needed_unit, expected_opts).and_return(action_double)
        expect(klass).to receive(:new).with(external_unit, expected_opts).and_return(action_double)
        expect(klass).to receive(:new).with(unit, expected_opts).and_return(action_double)
        expect(action_double).to receive(:execute!).exactly(5).times
        subject.create!(deep: true)
      end
    end

    describe '#purge!' do
      let(:klass) { Percheron::Actions::Purge }
      let(:action_double) { double('Percheron::Actions::Purge') }

      it 'asks each Unit to purge' do
        expect(klass).to receive(:new).with(pseudo2_unit, force: false).and_return(action_double)
        expect(klass).to receive(:new).with(pseudo1_unit, force: false).and_return(action_double)
        expect(klass).to receive(:new).with(needed_unit, force: false).and_return(action_double)
        expect(klass).to receive(:new).with(external_unit, force: false).and_return(action_double)
        expect(klass).to receive(:new).with(unit, force: false).and_return(action_double)
        expect(action_double).to receive(:execute!).exactly(5).times
        subject.purge!
      end
    end
  end

  describe '#valid?' do
    it 'is true' do
      expect(subject.valid?).to be(true)
    end
  end
end
