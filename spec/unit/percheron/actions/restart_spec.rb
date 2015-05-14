require 'unit/spec_helper'

describe Percheron::Actions::Restart do
  let(:dependant_unit) { double('Perheron::Unit') }
  let(:dependant_units) { [ dependant_unit ] }
  let(:unit) do
    double(
      'Perheron::Unit',
      name: 'debian',
      dependant_units: { 'dependant_debian' => dependant_unit },
      dependant_unit_names: %w(dependant_debian),
      startable_dependant_units: { 'dependant_unit' => dependant_unit }
    )
  end

  let(:stop_action) { double('Percheron::Actions::Stop') }
  let(:start_action) { double('Percheron::Actions::Start') }

  subject { described_class.new(unit) }

  describe '#execute!' do
    it 'asks Actions::Stop and Actions::Start to execute' do
      expect(Percheron::Actions::Stop).to receive(:new).with(unit).and_return(stop_action)
      expect(stop_action).to receive(:execute!)

      expect(Percheron::Actions::Start).to receive(:new).with(unit, dependant_units: dependant_units).and_return(start_action)
      expect(start_action).to receive(:execute!)

      subject.execute!
    end
  end
end
