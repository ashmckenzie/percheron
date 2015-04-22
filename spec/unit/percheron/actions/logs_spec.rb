require 'unit/spec_helper'

describe Percheron::Actions::Logs do
  let(:logger) { double('Logger').as_null_object }
  let(:container) { double('Percheron::Container').as_null_object }

  before do
    $logger = logger
  end

  after do
    $logger = nil
  end

  subject { described_class.new(container, options) }

  describe '#execute!' do
    context 'with no options' do
      let(:options) { {} }
      it 'displays the logs' do
        expect(container.docker_container).to receive(:logs).with(stdout: true, stderr: true, timestamps: true, tail: 100)
        subject.execute!
      end
    end

    context 'with follow option set' do
      let(:options) { { follow: true } }
      it 'displays and follows the logs' do
        expect(container.docker_container).to receive(:streaming_logs).with(stdout: true, stderr: true, timestamps: true, tail: 100, follow: true)
        subject.execute!
      end

      context 'and CTRL-C is pressed' do
        it 'handles the exception' do
          expect(container.docker_container).to receive(:streaming_logs).and_raise(Interrupt)
          expect(subject.execute!).to be_nil
        end
      end
    end
  end
end
