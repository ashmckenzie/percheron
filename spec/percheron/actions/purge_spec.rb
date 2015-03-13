require 'spec_helper'

describe Percheron::Actions::Purge do

  let(:logger) { double('Logger').as_null_object }
  let(:container) { double('Percheron::Container').as_null_object }

  before do
    $logger = logger
  end

  after do
    $logger = nil
  end

  subject { described_class.new(container) }

  describe '#execute!' do
    let(:stop_action) { double('Percheron::Actions::Stop') }

    before do
      expect(container).to receive(:exists?).and_return(true)
      expect(container).to receive(:image_exists?).and_return(true)
    end

    it 'asks Actions::Stop and Actions::Start to execute' do
      expect(Percheron::Actions::Stop).to receive(:new).with(container).and_return(stop_action)
      expect(stop_action).to receive(:execute!)

      expect(container.docker_container).to receive(:remove)
      expect(container.image).to receive(:remove)

      subject.execute!
    end

  end
end
