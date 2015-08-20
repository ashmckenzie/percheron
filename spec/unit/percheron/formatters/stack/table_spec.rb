require 'unit/spec_helper'

describe Percheron::Formatters::Stack::Table do
  let(:config_file_name) { './spec/unit/support/.percheron_valid_table.yml' }
  let(:config) { Percheron::Config.load!(config_file_name) }
  let(:stack) { Percheron::Stack.new(config, 'debian_jessie') }

  subject { described_class.new(stack) }

  before do
    $logger = double('Logger').as_null_object
  end

  describe '#generate' do
    context 'when none of the images or units exist' do
      it 'returns a Terminal::Table' do
        expect(Percheron::Connection).to receive(:perform).with(Docker::Container, :get, anything).and_raise(Docker::Error::NotFoundError).exactly(11).times
        expect(Percheron::Connection).to receive(:perform).with(Docker::Image, :get, anything).and_raise(Docker::Error::NotFoundError).exactly(3).times
        expect(subject.generate).to be_a(Terminal::Table)
      end
    end

    context 'when the images and units exist' do
      let(:container_info) { { 'id' => 'abc123', 'Config' => { 'Labels' => { 'version' => '1.0.0' } }, 'NetworkSettings' => { 'IPAddress' => '1.1.1.1' }, 'State' => { 'Running' => false } } }
      let(:container_double) { double('Docker::Container', info: container_info) }
      let(:image_info) { { 'VirtualSize' => 123_456_789 } }
      let(:image_double) { double('Docker::Image', info: image_info) }

      it 'returns a Terminal::Table' do
        expect(Percheron::Connection).to receive(:perform).with(Docker::Container, :get, anything).and_return(container_double).exactly(25).times
        expect(Percheron::Connection).to receive(:perform).with(Docker::Image, :get, anything).and_return(image_double).exactly(6).times
        expect(subject.generate).to be_a(Terminal::Table)
      end
    end
  end
end
