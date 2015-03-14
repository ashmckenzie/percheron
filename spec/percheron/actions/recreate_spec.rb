require 'spec_helper'

describe Percheron::Actions::Recreate do

  let(:logger) { double('Logger').as_null_object }
  let(:metastore) { double('Metastore::Cabinet') }

  let(:config) { Percheron::Config.new('./spec/support/.percheron_valid.yml') }
  let(:stack) { Percheron::Stack.new(config, 'debian_jessie') }
  let(:container) { Percheron::Container.new(config, stack, 'debian') }
  let(:opts) { {} }

  subject { described_class.new(container, opts) }

  before do
    Timecop.freeze(Time.local(1990))
    $metastore = metastore
    $logger = logger
  end

  after do
    Timecop.return
    $metastore = $logger = nil
  end

  describe '#execute!' do
    context 'when force_create is false' do
      let(:opts) { { force_recreate: false } }

      before do
        expect(container).to receive(:dockerfile_md5).and_return(stored_dockerfile_md5).twice
      end

      context 'and there are no Dockerfile changes' do
        let(:stored_dockerfile_md5) { nil }

        it 'logs Docker Container does not need to be recreated' do
          expect(logger).to receive(:info).with("Container 'debian' does not need to be recreated")
          subject.execute!
        end
      end

      context 'and there are Dockerfile changes' do
        let(:stored_dockerfile_md5) { 'abc123' }

        it 'warns the Docker Container should be recreated' do
          expect(logger).to receive(:warn).with("Container 'debian' MD5's do not match, consider recreating (bump the version!)")
          subject.execute!
        end
      end
    end

    context 'when force_create is true' do
      let(:create_action) { double('Percheron::Actions::Create') }
      let(:rename_action) { double('Percheron::Actions::Rename') }

      context 'and the temporary Docker container does not exist' do
        before do
          expect(Docker::Container).to receive(:get).with('debian_wip').and_raise(Docker::Error::NotFoundError)

          expect(Percheron::Actions::Create).to receive(:new).with(container, recreate: true).and_return(create_action)
          expect(create_action).to receive(:execute!).with({ create: { "name" => "debian_wip" } })

          expect(Percheron::Actions::Rename).to receive(:new).with(container, 'debian_wip', 'debian').and_return(rename_action)
          expect(rename_action).to receive(:execute!)
        end

        context 'and delete is false' do
          let(:opts) { { force_recreate: true, delete: false } }

          it 'asks to create Docker Image / Container' do
            subject.execute!
          end
        end

        context 'and delete is true' do
          let(:opts) { { force_recreate: true, delete: true } }
          let(:docker_container) { double('Docker::Container') }
          let(:docker_image) { double('Docker::Image') }

          it 'deletes the Docker Image and Container' do
            expect(subject).to receive(:stop_containers!).with([ container ])

            expect(container).to receive(:docker_container).and_return(docker_container)
            expect(docker_container).to receive(:remove)

            allow(container).to receive(:image).and_return(docker_image)
            expect(docker_image).to receive(:remove)

            subject.execute!
          end
        end
      end

      context 'and the temporary Docker container already exists' do
        let(:opts) { { force_recreate: true } }
        let(:temporary_container) { double('Docker::Container') }

        before do
          expect(Docker::Container).to receive(:get).with('debian_wip').and_return(temporary_container)
        end

        it 'warns that the temporary container already exists' do
          expect(logger).to receive(:debug).with("Not recreating 'debian' container because temporary container 'debian_wip' already exists")
          subject.execute!
        end
      end
    end
  end
end
