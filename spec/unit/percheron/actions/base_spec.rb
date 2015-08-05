require 'unit/spec_helper'

describe Percheron::Actions::Base do
  module Percheron
    module Actions
      class BaseClass
        include Percheron::Actions::Base

        def initialize(unit)
          @unit = unit
        end

        private

          attr_reader :unit
      end
    end
  end

  let(:logger) { double('Logger').as_null_object }
  let(:config) { Percheron::Config.load!('./spec/unit/support/.percheron_valid.yml') }
  let(:stack) { Percheron::Stack.new(config, 'debian_jessie') }
  let(:unit) { Percheron::Unit.new(config, stack, 'debian') }
  let(:dependant_units) { unit.dependant_units }

  before do
    $logger = logger
    Timecop.freeze(Time.local(1990))
    allow(unit).to receive(:dependant_units).and_return(dependant_units)
  end

  after do
    Timecop.return
    $logger = nil
  end

  subject { Percheron::Actions::BaseClass.new(unit) }

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
