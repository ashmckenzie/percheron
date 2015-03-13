require 'spec_helper'

describe Percheron::Actions::Restart do
  let(:dependant_container) { double('Perheron::Container') }
  let(:dependant_containers) { [ dependant_container ] }
  let(:container) { double('Perheron::Container', name: 'debian', dependant_containers: { 'dependant_debian' => dependant_container }, dependant_container_names: %w{dependant_debian}) }

  let(:stop_action) { double('Percheron::Actions::Stop') }
  let(:start_action) { double('Percheron::Actions::Start') }

  subject { described_class.new(container) }

  describe '#execute!' do
    it 'asks Actions::Stop and Actions::Start to execute' do
      expect(Percheron::Actions::Stop).to receive(:new).with(container).and_return(stop_action)
      expect(stop_action).to receive(:execute!)

      expect(Percheron::Actions::Start).to receive(:new).with(container, dependant_containers).and_return(start_action)
      expect(start_action).to receive(:execute!)

      subject.execute!
    end
  end
end
