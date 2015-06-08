require 'integration/spec_helper'

describe 'percheron' do
  before do
    $logger = double('Logger').as_null_object
    $metastore = double('Metastore').as_null_object
  end

  before(:all) do
    Dir.chdir(File.expand_path('../support', __FILE__))
    cleanup!
  end

  after do
    $logger = $metastore = nil
    cleanup!
  end

  describe 'create' do
    context 'for just the base unit' do
      it 'cannot create a unit as not startable' do
        Percheron::Commands::Create.run(Dir.pwd, %w(percheron-common base))
        expect { Docker::Container.get('percheron-common_base') }.to raise_error(Docker::Error::NotFoundError)
      end
    end

    context 'for just the app1 unit' do
      it 'creates a unit' do
        Percheron::Commands::Create.run(Dir.pwd, %w(percheron-test app1))
        output = Docker::Container.get('percheron-test_app1').json
        expect(output['Config']['Cmd']).to eql([ 'sh', '-c', "while true; do date ; echo 'hello from percheron'; done" ])
      end
    end

    context 'for just the app2 unit' do
      it 'creates a unit' do
        Percheron::Commands::Create.run(Dir.pwd, %w(--start percheron-test app2))
        output = Docker::Container.get('percheron-test_app2').json
        expect(output['Config']['Cmd']).to eql([ 'sh', '-c', "while true; do date ; echo 'hello from percheron'; done" ])
        expect(output['State']['Running']).to eql(true)
      end
    end

    context 'for all units' do
      it 'creates just the app1 unit' do
        Percheron::Commands::Create.run(Dir.pwd, %w(percheron-test))
        expect { Docker::Container.get('percheron-common_base') }.to raise_error(Docker::Error::NotFoundError)
        app1_output = Docker::Container.get('percheron-test_app1').json
        expect(app1_output['Config']['Cmd']).to eql([ 'sh', '-c', "while true; do date ; echo 'hello from percheron'; done" ])
      end
    end
  end
end
