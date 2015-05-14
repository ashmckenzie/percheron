require 'unit/spec_helper'

describe Percheron::Actions::Shell do
  let(:docker_client_validator) { double('Percheron::Validators::DockerClient', valid?: true) }
  let(:logger) { double('Logger').as_null_object }
  let(:unit) { double('Percheron::Unit', full_name: 'stack-unit').as_null_object }

  before do
    $logger = logger
  end

  after do
    $logger = nil
  end

  subject { described_class.new(unit) }

  describe '#execute!' do
    before do
      expect(Percheron::Validators::DockerClient).to receive(:new).and_return(docker_client_validator)
    end

    it 'calls docker exec' do
      expect(subject).to receive(:system).with("docker exec -ti stack-unit sh -c '/bin/sh'")
      subject.execute!
    end
  end
end
