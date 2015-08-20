require 'unit/spec_helper'

describe Percheron::Actions::Start do
  let(:container) { double('Docker::Container(container)', info: info) }
  let(:needed_container) { double('Docker::Container(needed_container)', info: needed_info) }
  let(:logger) { double('Logger').as_null_object }
  let(:exec_action) { double('Percheron::Actions::Exec') }
  let(:config) { Percheron::Config.load!('./spec/unit/support/.percheron_valid.yml') }
  let(:stack) { Percheron::Stack.new(config, 'debian_jessie') }
  let(:unit) { Percheron::Unit.new(config, stack, 'debian') }
  let(:needed_units) { unit.needed_units.values }
  let(:info) { Hashie::Mash.new('State' => { 'Running' => unit_running }) }
  let(:needed_info) { Hashie::Mash.new('State' => { 'Running' => needed_unit_running }) }

  subject { described_class.new(unit, needed_units: needed_units) }

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
      allow(Percheron::Connection).to receive(:perform).with(Docker::Container, :get, 'debian_jessie_needed_debian').and_return(needed_container)
      allow(Percheron::Actions::Exec).to receive(:new).with(unit, needed_units, ['./post_start_script2.sh'], 'POST start').and_return(exec_action)
      allow(exec_action).to receive(:execute!)
    end

    context 'when the unit is not running' do
      before do
        expect(unit).to receive(:running?).and_return(unit_running).at_least(:once)
        expect(Percheron::Actions::Create).to receive(:new).with(unit, cmd: false).and_return(create_double)

        allow(create_double).to receive(:execute!)
        allow(container).to receive(:start!)
      end

      let(:unit_running) { false }

      context 'and the needed units are already running' do
        let(:needed_unit_running) { true }

        include_examples 'an Actions::Start'
      end

      context 'and the needed units are already running' do
        let(:needed_unit_running) { false }

        it 'should ask Actions::Create to execute' do
          expect(create_double).to receive(:execute!)
          subject.execute!
        end
      end
    end

    context 'when the unit is running' do
      let(:unit_running) { true }

      context 'and the needed units are already running' do
        let(:needed_unit_running) { true }

        it 'does not try to start the Unit' do
          expect(container).to_not receive(:start!)
          subject.execute!
        end
      end
    end
  end
end
