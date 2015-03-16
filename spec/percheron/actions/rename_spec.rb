require 'spec_helper'

describe Percheron::Actions::Rename do
  let(:logger) { double('Logger').as_null_object }
  let(:docker_container1) { double('Docker::Container') }
  let(:docker_container2) { double('Docker::Container') }
  let(:docker_container3) { double('Docker::Container') }
  let(:container) { double('Percheron::Container', name: 'container_name', docker_container: docker_container1, running?: true, exists?: true).as_null_object }
  let(:temporary_name) { 'temporary_name' }
  let(:new_name) { 'new_name' }

  before do
    Timecop.freeze(Time.local(1990))
    $logger = logger
  end

  after do
    Timecop.return
    $logger = nil
  end

  subject { described_class.new(container, temporary_name, new_name) }

  describe '#execute!' do
    before do
      expect(Docker::Container).to receive(:get).with('temporary_name').and_return(docker_container2)
    end

    context 'when old container does not exist' do
      before do
        expect(Docker::Container).to receive(:get).with('container_name_19900101000000').and_raise(Docker::Error::NotFoundError)
      end

      it 'renames the Docker Container' do
        expect(subject).to receive(:stop_containers!).with([ container ])
        expect(docker_container1).to receive(:rename).with('container_name_19900101000000')
        expect(docker_container2).to receive(:rename).with('new_name')
        expect(subject).to receive(:start_containers!).with([ container ])
        expect(docker_container3).to_not receive(:remove)

        subject.execute!
      end
    end

    context 'when old container does exist' do
      before do
        expect(Docker::Container).to receive(:get).with('container_name_19900101000000').and_return(docker_container3).twice
      end

      it 'renames the Docker Container' do
        expect(subject).to receive(:stop_containers!).with([ container ])
        expect(docker_container1).to receive(:rename).with('container_name_19900101000000')
        expect(docker_container2).to receive(:rename).with('new_name')
        expect(subject).to receive(:start_containers!).with([ container ])
        expect(docker_container3).to receive(:remove)

        subject.execute!
      end
    end
  end
end
