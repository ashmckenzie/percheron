require 'unit/spec_helper'

describe Percheron::Actions::Recreate do
  let(:logger) { double('Logger').as_null_object }
  let(:metastore) { double('Metastore::Cabinet') }
  let(:config) { Percheron::Config.new('./spec/unit/support/.percheron_valid.yml') }
  let(:stack) { Percheron::Stack.new(config, 'debian_jessie') }
  let(:container) { Percheron::Container.new(stack, 'debian', config.file_base_path) }
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
    before do
      allow(container).to receive(:image_exists?).and_return(true)
      allow(container).to receive(:versions_match?).and_return(versions_match).at_least(:once)
      allow(container).to receive(:dockerfile_md5s_match?).and_return(dockerfile_md5s_match).at_least(:once)
    end

    context 'where there are no Dockerfile changes' do
      let(:dockerfile_md5s_match) { true }

      context 'and the version defined does match' do
        let(:versions_match) { true }

        it 'logs Docker Container does not need to be recreated' do
          expect(logger).to receive(:info).with("Container 'debian' - No Dockerfile changes or version bump")
          subject.execute!
        end
      end
    end

    context 'where there are Dockerfile changes' do
      let(:dockerfile_md5s_match) { false }

      let(:create_action) { double('Percheron::Actions::Create') }
      let(:purge_action) { double('Percheron::Actions::Purge') }

      let(:docker_container) { double('Docker::Container') }
      let(:docker_image) { double('Docker::Image') }

      context 'and the version defined does match' do
        let(:versions_match) { true }

        it 'deletes the Docker Image and Container' do
          expect(Percheron::Actions::Create).to receive(:new).with(container).and_return(create_action)
          expect(create_action).to receive(:execute!)
          expect(Percheron::Actions::Purge).to receive(:new).with(container).and_return(purge_action)
          expect(purge_action).to receive(:execute!)
          subject.execute!
        end
      end
    end
  end
end
