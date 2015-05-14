require 'unit/spec_helper'

describe Percheron::Actions::Purge do
  let(:logger) { double('Logger').as_null_object }
  let(:unit) { double('Percheron::Unit').as_null_object }

  before do
    $logger = logger
  end

  after do
    $logger = nil
  end

  subject { described_class.new(unit) }

  describe '#execute!' do
    let(:stop_action) { double('Percheron::Actions::Stop') }

    before do
      expect(unit).to receive(:exists?).and_return(true)
      expect(unit).to receive(:image_exists?).and_return(true)
    end

    it 'asks Actions::Stop and Actions::Start to execute' do
      expect(Percheron::Actions::Stop).to receive(:new).with(unit).and_return(stop_action)
      expect(stop_action).to receive(:execute!)
      expect(unit.container).to receive(:remove)
      expect(unit.image).to receive(:remove)
      subject.execute!
    end

    context 'when the unit cannot be removed' do
      it 'raises an exception' do
        expect(unit.container).to receive(:remove).and_raise(Docker::Error::ConflictError)
        expect(logger).to receive(:error).with(/Unable to delete .+ unit/)
        subject.execute!
      end
    end

    context 'when the image cannot be removed' do
      it 'raises an exception' do
        expect(unit.container).to receive(:remove)
        expect(unit.image).to receive(:remove).and_raise(Docker::Error::ConflictError)
        expect(logger).to receive(:error).with(/Unable to delete .+ image/)
        subject.execute!
      end
    end
  end
end
