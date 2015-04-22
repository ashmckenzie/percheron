require 'unit/spec_helper'

describe Percheron::Actions::Base do
  module Percheron
    module Actions
      class BaseClass
        include Percheron::Actions::Base

        def initialize(container)
          @container = container
        end

        private

          attr_reader :container
      end
    end
  end

  let(:logger) { double('Logger').as_null_object }
  let(:config) { Percheron::Config.new('./spec/unit/support/.percheron_valid.yml') }
  let(:stack) { Percheron::Stack.new(config, 'debian_jessie') }
  let(:container) { Percheron::Container.new(stack, 'debian', config.file_base_path) }
  let(:dependant_containers) { container.dependant_containers }

  before do
    $logger = logger
    Timecop.freeze(Time.local(1990))
    allow(container).to receive(:dependant_containers).and_return(dependant_containers)
  end

  after do
    Timecop.return
    $logger = nil
  end

  subject { Percheron::Actions::BaseClass.new(container) }

  describe '#base_dir' do
    it "returns the Dockerfile's base dir" do
      expect(subject.base_dir).to match(Regexp.new('.+/percheron/spec/unit/support'))
    end
  end

  describe '#in_working_directory' do
    it 'changes the working directory, yields, then returns to previous working directory' do
      expect(Dir).to receive(:pwd).and_return('/tmp/old')
      expect(Dir).to receive(:chdir).with('/tmp')
      expect(Dir).to receive(:chdir).with('/tmp/old')

      subject.in_working_directory('/tmp') { 'testing' }
    end
  end
end
