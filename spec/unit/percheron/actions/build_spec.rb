require 'unit/spec_helper'

describe Percheron::Actions::Build do
  let(:logger) { double('Logger').as_null_object }
  let(:exec_local_action) { double('Percheron::Actions::ExecLocal') }

  let(:config) { Percheron::Config.load!('./spec/unit/support/.percheron_valid.yml') }
  let(:stack) { Percheron::Stack.new(config, 'debian_jessie') }
  let(:unit) { Percheron::Unit.new(config, stack, 'debian') }
  let(:dependant_units) { unit.dependant_units }

  subject { described_class.new(unit) }

  before do
    $logger = logger
    allow(SecureRandom).to receive(:urlsafe_base64).and_return('temp1234')
    allow(unit).to receive(:dependant_units).and_return(dependant_units)
  end

  after do
    $logger = nil
  end

  describe '#execute!' do
    let(:out) { 'output from Docker::Image.build_from_dir()' }

    before do
      expected_opts = { 'dockerfile' => 'Dockerfile.temp1234', 't' => 'debian_jessie_debian:1.0.0', 'forcerm' => false, 'nocache' => false }
      allow(Percheron::Connection).to receive(:perform).with(Docker::Image, :build_from_dir, unit.dockerfile.dirname.to_s, expected_opts).and_yield(out)
      allow(Percheron::Actions::ExecLocal).to receive(:new).with(unit, ['./pre_build_script2.sh'], 'PRE build').and_return(exec_local_action)
      allow(exec_local_action).to receive(:execute!)
    end

    it 'executes pre build scripts' do
      expect(exec_local_action).to receive(:execute!)
      subject.execute!
    end

    it 'creates a Docker::Image' do
      expect(logger).to receive(:debug).with('output from Docker::Image.build_from_dir()')
      subject.execute!
    end
  end
end
