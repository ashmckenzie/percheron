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
    context 'when the Docker client is not installed' do
      before do
        expect(subject).to receive(:docker_client_exists?).and_return(false)
      end

      it 'raises an exception' do
        expect { subject.execute! }.to raise_error(Percheron::Errors::DockerClientNotInstalled)
      end
    end

    context 'when the Docker client is installed' do
      before do
        expect(subject).to receive(:docker_client_exists?).and_return(true)
        expect(subject).to receive(:docker_client_version_valid?).and_return(client_version_valid)
      end

      context 'but is an insufficient version' do
        let(:client_version_valid) { false }

        it 'raises an exception' do
          expect { subject.execute! }.to raise_error(Percheron::Errors::DockerClientInsufficientVersion)
        end
      end

      context 'and has a sufficient version' do
        let(:client_version_valid) { true }

        it 'calls docker exec' do
          expect(subject).to receive(:system).with('docker exec -ti stack-container /bin/sh')
          subject.execute!
        end
      end
    end
  end
end
