require 'unit/spec_helper'

describe Percheron::Actions::Logs do
  let(:logger) { double('Logger').as_null_object }
  let(:unit) { double('Percheron::Unit').as_null_object }

  before do
    $logger = logger
  end

  after do
    $logger = nil
  end

  subject { described_class.new(unit, options) }

  describe '#execute!' do
    context 'with no options' do
      let(:options) { {} }
      it 'displays the logs' do
        expect(unit.container).to receive(:logs).with(stdout: true, stderr: true, timestamps: true, tail: 100)
        subject.execute!
      end
    end

    context 'with follow option set' do
      let(:options) { { follow: true } }
      let(:stream) { :stdout }
      let(:chunk) { 'hello' }
      it 'displays and follows the logs' do
        expect(unit.container).to receive(:streaming_logs).with(stdout: true, stderr: true, timestamps: true, tail: 100, follow: true).and_yield(stream, chunk)
        subject.execute!
      end

      context 'and CTRL-C is pressed' do
        it 'handles the exception' do
          expect(unit.container).to receive(:streaming_logs).and_raise(Interrupt)
          expect(subject.execute!).to be_nil
        end
      end
    end
  end
end
