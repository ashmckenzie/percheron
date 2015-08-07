require 'unit/spec_helper'

describe Percheron::Graph do
  let(:logger) { double('Logger').as_null_object }
  let(:config) { Percheron::Config.load!('./spec/unit/support/.percheron_valid.yml') }
  let(:stack) { Percheron::Stack.new(config, 'debian_jessie') }
  let(:graph) { double('GraphViz').as_null_object }

  subject { described_class.new(stack) }

  before do
    expect(GraphViz).to receive(:new).with(:G, type: :digraph, nodesep: 0.75, ranksep: 1.0, label: "<\n          <table border=\"0\" cellborder=\"0\">\n            <tr><td height=\"36\" valign=\"bottom\">\n              <font face=\"Arial Bold\" point-size=\"14\">debian_jessie</font>\n            </td></tr>\n            <tr><td height=\"18\"><font face=\"Arial Italic\" point-size=\"11\"> </font></td></tr>\n          </table>\n          >").and_return(graph)
  end

  describe '#save!' do
    let(:file) { '/tmp/stack.png' }

    it 'saves a dependancy graph to disk' do
      expect(graph).to receive(:output).with(png: file)
      subject.save!(file)
    end
  end
end
