require 'unit/spec_helper'

describe Percheron::Actions::Start do
  let(:container) { double('Docker::Container') }
  let(:logger) { double('Logger').as_null_object }
  let(:exec_action) { double('Percheron::Actions::Exec') }
  let(:config) { Percheron::Config.load!('./spec/unit/support/.percheron_valid.yml') }
  let(:stack) { Percheron::Stack.new(config, 'debian_jessie') }
  let(:unit) { Percheron::Unit.new(config, stack, 'debian') }
  let(:dependant_units) { unit.dependant_units.values }

  subject { described_class.new(unit, dependant_units: dependant_units) }

  before do
    $logger = logger
  end

  after do
    $logger = nil
  end

  describe '#execute!' do
    let(:create_double) { double('Percheron::Actions::Create') }

    before do
      allow(Percheron::Connection).to receive(:perform).with(Docker::Container, :get, 'debian_jessie_debian').and_return(container)
      expect(unit).to receive(:exists?).and_return(unit_exists).at_least(:once)
      expect(unit).to receive(:running?).and_return(unit_running).at_least(:once)
      allow(Percheron::Actions::Exec).to receive(:new).with(unit, dependant_units, ['./post_start_script2.sh'], 'POST start').and_return(exec_action)
      allow(exec_action).to receive(:execute!)
    end

    context 'when the unit is not running' do
      before do
        allow(container).to receive(:start!)
      end

      let(:unit_running) { false }

      context 'when the unit does not exist' do
        let(:unit_exists) { false }

        before do
          expect(Percheron::Actions::Create).to receive(:new).with(unit, cmd: false).and_return(create_double)
          allow(create_double).to receive(:execute!)
        end

        it 'should ask Actions::Create to execute' do
          expect(create_double).to receive(:execute!)
          subject.execute!
        end

        include_examples 'an Actions::Start'
      end

      context 'when the unit does exist' do
        let(:unit_exists) { true }

        include_examples 'an Actions::Start'
      end
    end

    context 'when the unit is running' do
      let(:unit_exists) { true }
      let(:unit_running) { true }

      it 'does not try to start the Container' do
        expect(container).to_not receive(:start!)
        subject.execute!
      end
    end
  end
end
