require 'spec_helper'

describe Percheron::Actions::Stop do

  let(:logger) { double('Logger').as_null_object }

  let(:config) { Percheron::Config.new('./spec/support/.percheron_valid.yml') }
  let(:stack) { Percheron::Stack.new(config, 'debian_jessie') }
  let(:container) { Percheron::Container.new(config, stack, 'debian') }

  subject { described_class.new(container) }

  before do
    $logger = logger
    expect(container).to receive(:running?).and_return(true)
  end

  after do
    $logger = nil
  end

  describe '#execute!' do
    let(:docker_container) { double('Docker::Container') }

    before do
      expect(container).to receive(:docker_container).and_return(docker_container)
    end

    it 'stops the container' do
      expect(docker_container).to receive(:stop!)
      subject.execute!
    end
  end
end
