require 'spec_helper'

describe Percheron::Container::Actions::Build do

  let(:logger_double) { double('Logger') }

  let(:config) { Percheron::Config.new('./spec/fixtures/.percheron_valid.yml') }
  let(:stack) { Percheron::Stack.new(config, 'debian_jessie') }
  let(:container_name) { 'debian' }
  let(:container) { Percheron::Container::Main.new(config, stack, container_name) }

  let(:expected_opts) { {"dockerfile"=>"Dockerfile", "t"=>"debian:1.0.0", "forcerm"=>true, "nocache"=>false} }

  subject { described_class.new(container) }

  before do
    $logger = logger_double
  end

  describe '#execute!' do
    let(:out) { 'output from Docker::Image.build_from_dir()' }

    it 'creates a Docker::Container' do
      expect(logger_double).to receive(:debug).with(Regexp.new("Executing PRE build '/bin/bash -x .+/percheron/spec/fixtures/pre_build_script.sh 2>&1' for 'debian' container"))
      expect(logger_double).to receive(:debug).with(/echo 'PRE build script'/)
      expect(logger_double).to receive(:debug).with("PRE build script")
      expect(logger_double).to receive(:debug).with("Building 'debian:1.0.0'")
      expect(Docker::Image).to receive(:build_from_dir).with(container.dockerfile.dirname.to_s, expected_opts).and_yield(out)
      expect(logger_double).to receive(:debug).with(out)
      subject.execute!
    end
  end
end
