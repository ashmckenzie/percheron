require 'unit/spec_helper'

describe Percheron::Actions::Shell do
  let(:logger) { double('Logger').as_null_object }
  let(:container) { double('Percheron::Container', full_name: 'stack-container').as_null_object }

  before do
    $logger = logger
  end

  after do
    $logger = nil
  end

  subject { described_class.new(container) }

  describe '#execute!' do
    it 'calls docker exec' do
      expect(subject).to receive(:system).with('docker exec -ti stack-container /bin/sh')
      subject.execute!
    end
  end
end
