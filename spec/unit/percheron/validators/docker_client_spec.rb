require 'unit/spec_helper'

describe Percheron::Validators::DockerClient do
  subject { described_class.new }

  describe '#valid?' do
    context 'when the Docker client is not installed' do
      it 'raises exception' do
        expect(ENV).to receive(:[]).with('PATH').and_return('')
        expect { subject.valid? }.to raise_error(Percheron::Errors::DockerClientInvalid, 'Docker client is invalid: Is not in your PATH')
      end
    end

    context 'when the Docker client is installed' do
      let(:docker_client) { double('File') }

      before do
        expect(ENV).to receive(:[]).with('PATH').and_return('/tmp').twice
        expect(File).to receive(:join).with('/tmp', 'docker').and_return(docker_client).twice
        expect(File).to receive(:executable?).with(docker_client).and_return(true).twice
        expect(File).to receive(:directory?).with(docker_client).and_return(false).twice
        expect(subject).to receive(:`).with('docker --version').and_return(version)
      end

      context 'but is not the minimum version' do
        let(:version) { 'Docker version 1.5.0, build 1234567\n"' }
        it 'raises exception' do
          expect { subject.valid? }.to raise_error(Percheron::Errors::DockerClientInvalid, /Docker client is invalid: Version is insufficient, need \d+\.\d+\.\d+$/)
        end
      end

      context 'and is at least the minimum version' do
        let(:version) { 'Docker version 1.6.0, build 1234567\n"' }
        it 'returns true' do
          expect(subject.valid?).to eql(true)
        end
      end
    end
  end
end
