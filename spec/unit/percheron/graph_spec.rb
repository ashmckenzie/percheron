require 'unit/spec_helper'

describe Percheron::Graph do
  let(:logger) { double('Logger').as_null_object }
  let(:config) { Percheron::Config.load!('./spec/unit/support/.percheron_valid.yml') }
  let(:stack) { Percheron::Stack.new(config, 'debian_jessie') }
  let(:graph) { double('GraphViz').as_null_object }

  subject { described_class.new(stack) }

  before do
    expect(GraphViz).to receive(:new).with(:G, type: :digraph, nodesep: 0.75, ranksep: 1.0, label: '\ndebian_jessie\n\n', fontsize: 12).and_return(graph)
  end

  describe '#save!' do
    let(:file) { '/tmp/stack.png' }

    it 'saves a dependancy graph to disk' do
      expect(graph).to receive(:output).with(png: file)
      subject.save!(file)
    end
  end
end
