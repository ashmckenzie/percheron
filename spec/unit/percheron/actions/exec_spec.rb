# require 'unit/spec_helper'
#
# describe Percheron::Actions::Exec do
#   let(:logger) { double('Logger').as_null_object }
#   let(:stop_action) { double('Percheron::Actions::Stop') }
#   let(:start_action1) { double('Percheron::Actions::Start') }
#   let(:start_action2) { double('Percheron::Actions::Start') }
#   let(:container) { double('Docker::Container').as_null_object }
#   let(:docker_image) { double('Docker::Image') }
#
#   let(:config) { Percheron::Config.load!('./spec/unit/support/.percheron_valid.yml') }
#   let(:stack) { Percheron::Stack.new(config, 'debian_jessie') }
#   let(:unit) { Percheron::Unit.new(config, stack, 'debian') }
#   let(:needed_units) { unit.needed_units.values }
#   let(:needed_unit) { needed_units.first }
#   let(:scripts) { [ '/tmp/test.sh' ] }
#
#   subject { described_class.new(unit, needed_units, scripts, 'TEST') }
#
#   before do
#     $logger = logger
#   end
#
#   after do
#     $logger = nil
#   end
#
#   describe '#execute!' do
#     before do
#       expect(unit).to receive(:running?).twice.and_return(false)
#       expect(unit).to receive(:container).and_return(container).twice
#     end
#
#     it 'executes scripts' do
#       expect(Percheron::Actions::Start).to receive(:new).with(needed_unit, needed_units: [], exec_scripts: true).and_return(start_action1)
#       expect(Percheron::Actions::Start).to receive(:new).with(unit, exec_scripts: false).and_return(start_action2)
#       expect(start_action1).to receive(:execute!).and_return(needed_unit)
#       expect(start_action2).to receive(:execute!).and_return(unit)
#       expect(container).to receive(:exec).with(['/bin/sh', '-x', '/tmp/test.sh', '2>&1']).and_yield(:stdout, 'output from test.sh')
#       subject.execute!
#     end
#   end
# end
