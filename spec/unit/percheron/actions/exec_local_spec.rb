require 'unit/spec_helper'

describe Percheron::Actions::ExecLocal do
  let(:logger) { double('Logger').as_null_object }
  let(:config) { Percheron::Config.load!('./spec/unit/support/.percheron_valid.yml') }
  let(:stack) { Percheron::Stack.new(config, 'debian_jessie') }
  let(:unit) { Percheron::Unit.new(config, stack, 'debian') }
  let(:scripts) { [ '/tmp/test.sh' ] }
  let(:output) { double('stdout_stderr') }

  subject { described_class.new(unit, scripts, 'TEST') }

  before do
    $logger = logger
  end

  after do
    $logger = nil
  end

  describe '#execute!' do
    it 'executes scripts locally' do
      expect(output).to receive(:gets).and_return("output from test.sh\n", false)
      expect(Open3).to receive(:popen2e).with('/tmp/test.sh 2>&1').and_yield(nil, output, nil)
      expect(logger).to receive(:debug).with('output from test.sh')

      subject.execute!
    end
  end
end
