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

    before do
      expect(logger_double).to receive(:debug).with("Building 'debian:1.0.0'")
    end

    it 'creates a Docker::Container' do
      expect(logger_double).to receive(:debug).with(out)
      expect(Docker::Image).to receive(:build_from_dir).with(container.dockerfile.dirname.to_s, expected_opts).and_yield(out)
      subject.execute!
    end
  end

end
