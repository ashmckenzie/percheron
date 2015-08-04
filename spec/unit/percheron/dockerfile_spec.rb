# require 'unit/spec_helper'
#
# describe Percheron::Dockerfile do
#   let(:logger) { double('Logger').as_null_object }
#   let(:metastore) { double('Metastore::Cabinet') }
#
#   subject { described_class.new('./spec/unit/support/.percheron_valid.yml') }
#
#   before do
#     $logger = logger
#     $metastore = metastore
#   end
#
#   after do
#     $logger = $metastore = nil
#   end
#
#   describe '#dockerfile' do
#     it 'returns a Pathname object' do
#       expect(subject.dockerfile).to be_a(Pathname)
#     end
#   end
#
#   describe '#update_md5!' do
#     context 'when a Dockerfile is not defined but a Docker image is' do
#       it 'updates the metastore' do
#         expect(metastore).to receive(:set).with('stacks.debian_jessie.units.debian.md5', '0b03152a88e90de1c5466d6484b8ce5b')
#         subject.update_md5!
#       end
#     end
#
#     context 'when a Dockerfile is defined and Docker image is not' do
#       it 'updates the metastore' do
#         expect(metastore).to receive(:set).with('stacks.debian_jessie.units.debian.md5', '0b03152a88e90de1c5466d6484b8ce5b')
#         subject.update_md5!
#       end
#     end
#   end
#
#   describe '#md5s_match?' do
#     before do
#       expect(metastore).to receive(:get).with('stacks.debian_jessie.units.debian.md5').and_return(md5)
#     end
#
#     context 'when the Docker unit has never been built' do
#       let(:md5) { nil }
#
#       it 'returns true' do
#         expect(subject.md5s_match?).to be(true)
#       end
#     end
#
#     context 'when the Docker unit has been built in the past' do
#       let(:md5) { '1234' }
#
#       it 'returns true' do
#         expect(subject.md5s_match?).to be(false)
#       end
#     end
#   end
# end
