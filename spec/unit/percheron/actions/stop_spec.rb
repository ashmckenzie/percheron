require 'unit/spec_helper'

describe Percheron::Actions::Stop do
  let(:logger) { double('Logger').as_null_object }
  let(:config) { Percheron::Config.new('./spec/unit/support/.percheron_valid.yml') }
  let(:stack) { Percheron::Stack.new(config, 'debian_jessie') }
  let(:unit) { Percheron::Unit.new(config, stack, 'debian') }

  subject { described_class.new(unit) }

  before do
    $logger = logger
    expect(unit).to receive(:running?).and_return(true)
  end

  after do
    $logger = nil
  end

  describe '#execute!' do
    let(:container) { double('Docker::Container') }

    before do
      expect(unit).to receive(:container).and_return(container)
    end

    it 'stops the unit' do
      expect(container).to receive(:stop!)
      subject.execute!
    end
  end
end
