require 'integration/spec_helper'

describe 'percheron' do
  before do
    $logger = double('Logger').as_null_object
    $metastore = double('Metastore').as_null_object
  end

  before(:all) do
    Dir.chdir('./spec/integration/support')
    cleanup!
  end

  after do
    $logger = $metastore = nil
    cleanup!
  end

  describe 'create' do
    context 'for just the base container' do
      it 'cannot create a container as not startable' do
        Percheron::Commands::Create.run(Dir.pwd, %w(percheron-test base))
        expect { Docker::Container.get('percheron-test_base') }.to raise_error(Docker::Error::NotFoundError)
      end
    end

    context 'for just the app1 container' do
      it 'creates a container' do
        Percheron::Commands::Create.run(Dir.pwd, %w(percheron-test app1))
        output = Docker::Container.get('percheron-test_app1').json
        expect(output['Config']['Cmd']).to eql([ 'sh', '-c', "while true; do date ; echo 'hello from percheron'; done" ])
      end
    end

    context 'for just the app2 container' do
      it 'creates a container' do
        Percheron::Commands::Create.run(Dir.pwd, %w(--start percheron-test app2))
        output = Docker::Container.get('percheron-test_app2').json
        expect(output['Config']['Cmd']).to eql([ 'sh', '-c', "while true; do date ; echo 'hello from percheron'; done" ])
        expect(output['State']['Running']).to eql(true)
      end
    end

    context 'for all containers' do
      it 'creates just the app1 container' do
        Percheron::Commands::Create.run(Dir.pwd, %w(percheron-test))
        expect { Docker::Container.get('percheron-test_base') }.to raise_error(Docker::Error::NotFoundError)
        app1_output = Docker::Container.get('percheron-test_app1').json
        expect(app1_output['Config']['Cmd']).to eql([ 'sh', '-c', "while true; do date ; echo 'hello from percheron'; done" ])
      end
    end
  end
end
