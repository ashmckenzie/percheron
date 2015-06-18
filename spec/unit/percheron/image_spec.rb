require 'unit/spec_helper'

describe Percheron::Image do
  let(:image_name) { 'debian_jessie_debian:1.0.0' }

  subject { described_class.new(image_name) }

  describe '#id' do
    context 'when the Docker Image does not exist' do
      before do
        expect(Percheron::Connection).to receive(:perform).with(Docker::Image, :get, image_name).and_raise(Percheron::Errors::ConnectionException)
      end

      it 'returns false' do
        expect(subject.id).to be_nil
      end
    end

    context 'when the Docker Image does exist' do
      let(:docker_image_double) { double('Docker::Image', id: '5d6cb3bdb606ZZ') }

      before do
        expect(Percheron::Connection).to receive(:perform).with(Docker::Image, :get, image_name).and_return(docker_image_double)
      end

      it 'returns the id' do
        expect(subject.id).to eql('5d6cb3bdb606')
      end
    end
  end

  describe '#exists?' do
    context 'when the Docker Image does not exist' do
      before do
        expect(Percheron::Connection).to receive(:perform).with(Docker::Image, :get, image_name).and_raise(Percheron::Errors::ConnectionException)
      end

      it 'returns false' do
        expect(subject.exists?).to be(false)
      end
    end

    context 'when the Docker Image does exist' do
      let(:docker_image_double) { double('Docker::Image', id: '5d6cb3bdb606') }

      before do
        expect(Percheron::Connection).to receive(:perform).with(Docker::Image, :get, image_name).and_return(docker_image_double)
      end

      it 'returns true' do
        expect(subject.exists?).to be(true)
      end
    end
  end
end
