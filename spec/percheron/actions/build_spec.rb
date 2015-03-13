require 'spec_helper'

describe Percheron::Actions::Build do

  let(:logger) { double('Logger').as_null_object }
  let(:exec_local_action) { double('Percheron::Actions::ExecLocal') }

  let(:config) { Percheron::Config.new('./spec/support/.percheron_valid.yml') }
  let(:stack) { Percheron::Stack.new(config, 'debian_jessie') }
  let(:container) { Percheron::Container.new(config, stack, 'debian') }
  let(:dependant_containers) { container.dependant_containers }

  let(:expected_opts) { {"dockerfile"=>"Dockerfile", "t"=>"debian:1.0.0", "forcerm"=>true, "nocache"=>false} }

  subject { described_class.new(container) }

  before do
    $logger = logger
    allow(container).to receive(:dependant_containers).and_return(dependant_containers)
  end

  after do
    $logger = nil
  end

  describe '#execute!' do
    let(:out) { 'output from Docker::Image.build_from_dir()' }

    before do
      allow(Docker::Image).to receive(:build_from_dir).with(container.dockerfile.dirname.to_s, expected_opts).and_yield(out)
      allow(Percheron::Actions::ExecLocal).to receive(:new).with(container, ["./pre_build_script2.sh"], 'PRE build').and_return(exec_local_action)
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
