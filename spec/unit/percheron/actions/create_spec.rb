require 'unit/spec_helper'

describe Percheron::Actions::Create do
  let(:logger) { double('Logger').as_null_object }
  let(:metastore) { double('Metastore::Cabinet') }
  let(:build_double) { double('Percheron::Actions::Build') }

  let(:config) { Percheron::Config.load!('./spec/unit/support/.percheron_valid.yml') }
  let(:stack) { Percheron::Stack.new(config, 'debian_jessie') }

  let(:new_opts) { {} }

  subject { described_class.new(unit, new_opts) }

  before do
    $logger = logger
    $metastore = metastore
  end

  after do
    $logger = $metastore = nil
  end

  describe '#execute!' do
    before do
      expect(unit).to receive(:exists?).and_return(unit_exists)
    end

    context 'when a Docker Container does not exist' do
      let(:unit_exists) { false }
      let(:image) { double('Docker::Image') }
      let(:new_image) { double('Docker::Image') }

      before do
        expect(unit).to receive(:image_exists?).and_return(false, image_exists)
        expect(Percheron::Connection).to receive(:perform).with(Docker::Container, :create, create_options)
        expect(metastore).to receive(:set).with(metastore_key, metastore_key_md5)
      end

      context 'for a non-buildable Docker unit' do
        let(:unit) { Percheron::Unit.new(config, stack, 'debian_external') }
        let(:image_exists) { false }
        let(:create_options) do
          {
            'name' => 'debian_jessie_debian_external',
            'Image' => 'debian:jessie',
            'Hostname' => 'debian_external',
            'Env' => [],
            'ExposedPorts' => {},
            'Cmd' => [],
            'Labels' => { version: '1.0.0', created_by: /Percheron \d+\.\d+\.\d+/ },
            'HostConfig' => {
              'PortBindings' => {},
              'Links' => [],
              'Binds' => [],
              'Dns' => [ '127.0.0.1', '8.8.8.8' ]
            }
          }
        end
        let(:metastore_key) { 'stacks.debian_jessie.units.debian_external.dockerfile_md5' }
        let(:metastore_key_md5) { '02ce896e512816bf86458b581255d20c' }

        it 'pulls down the Docker image' do
          expect(JSON).to receive(:parse).with(fromImage: 'debian:jessie')
          expect(Percheron::Connection).to receive(:perform).with(Docker::Image, :create, fromImage: 'debian:jessie').and_yield(fromImage: 'debian:jessie')
          subject.execute!
        end
      end

      context 'for a buildable Docker unit' do
        let(:unit) { Percheron::Unit.new(config, stack, 'debian') }
        let(:dependant_units) { unit.dependant_units }
        let(:create_options) do
          {
            'name' => 'debian_jessie_debian',
            'Image' => 'debian_jessie_debian:1.0.0',
            'Hostname' => 'debian',
            'Env' => [],
            'ExposedPorts' => {
              '9999' => {}
            },
            'Cmd' => [],
            'Labels' => { version: '1.0.0', created_by: /Percheron \d+\.\d+\.\d+/ },
            'HostConfig' => {
              'PortBindings' => {
                '9999' => [ { 'HostPort' => '9999' } ]
              },
              'Links' => [ 'debian_jessie_dependant_debian:dependant_debian' ],
              'Binds' => [ '/outside/container/path:/inside/container/path' ],
              'Dns' => [ '127.0.0.1', '8.8.8.8' ]
            }
          }
        end
        let(:metastore_key) { 'stacks.debian_jessie.units.debian.dockerfile_md5' }
        let(:metastore_key_md5) { '0b03152a88e90de1c5466d6484b8ce5b' }

        before do
          expect(unit).to receive(:dependant_units).and_return(dependant_units)
          expect(unit).to receive(:image).and_return(image)
        end

        context 'and Docker image does not exist' do
          let(:image_exists) { false }

          it 'calls Actions::Build#execute! AND creates a Docker::Container' do
            expect(Percheron::Actions::Build).to receive(:new).with(unit).and_return(build_double)
            expect(build_double).to receive(:execute!)
            expect(image).to receive(:insert_local).with('localPath' => %r{/spec/unit/support/post_start_script2.sh}, 'outputPath' => '/tmp/post_start_script2.sh').and_return(new_image)
            expect(new_image).to receive(:tag).with(repo: 'debian_jessie_debian', tag: '1.0.0', force: true)
            subject.execute!
          end
        end

        context 'and a Docker image already exists' do
          let(:image_exists) { true }

          it 'creates just a Docker::Container' do
            expect(Percheron::Actions::Build).to_not receive(:new).with(unit)
            expect(image).to receive(:insert_local).with('localPath' => %r{/spec/unit/support/post_start_script2.sh}, 'outputPath' => '/tmp/post_start_script2.sh').and_return(new_image)
            expect(new_image).to receive(:tag).with(repo: 'debian_jessie_debian', tag: '1.0.0', force: true)
            subject.execute!
          end

          context 'and the Container should start' do
            let(:new_opts) { { start: true } }
            let(:start_double) { double('Percheron::Actions::Start') }

            it 'starts up the Docker::Container' do
              expect(Percheron::Actions::Build).to_not receive(:new).with(unit)
              expect(image).to receive(:insert_local).with('localPath' => %r{/spec/unit/support/post_start_script2.sh}, 'outputPath' => '/tmp/post_start_script2.sh').and_return(new_image)
              expect(new_image).to receive(:tag).with(repo: 'debian_jessie_debian', tag: '1.0.0', force: true)
              expect(Percheron::Actions::Start).to receive(:new).with(unit).and_return(start_double)
              expect(start_double).to receive(:execute!)
              subject.execute!
            end
          end
        end
      end
    end

    context 'when a Docker unit already exists' do
      let(:unit_exists) { true }
      let(:unit) { Percheron::Unit.new(config, stack, 'debian') }

      before do
        expect(unit).to receive(:image_exists?).and_return(true)
      end

      it 'creates a Docker::Container' do
        expect(logger).to receive(:debug).with("Unit 'debian' already exists")
        subject.execute!
      end
    end
  end
end
