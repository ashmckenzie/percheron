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

  describe 'start' do
    context 'for just the base unit' do
      it 'cannot create a unit as not startable' do
        Percheron::Commands::Start.run(Dir.pwd, %w(percheron-test base))
        expect { Docker::Container.get('percheron-test_base') }.to raise_error(Docker::Error::NotFoundError)
      end
    end

    context 'for just the app1 unit' do
      it 'starts the unit' do
        Percheron::Commands::Start.run(Dir.pwd, %w(percheron-test app1))
        output = Docker::Container.get('percheron-test_app1').json
        expect(output['State']['Running']).to eql(true)
      end
    end

    context 'for just the app2 unit' do
      it 'starts the unit' do
        Percheron::Commands::Start.run(Dir.pwd, %w(percheron-test app2))
        output = Docker::Container.get('percheron-test_app2').json
        expect(output['State']['Running']).to eql(true)
      end
    end

    context 'for just the app3 unit' do
      it 'starts the unit' do
        Percheron::Commands::Start.run(Dir.pwd, %w(percheron-test app3))
        output = Docker::Container.get('percheron-test_app3').json
        expect(output['State']['Running']).to eql(true)
      end
    end

    context 'for all units' do
      it 'starts just the app1 unit' do
        Percheron::Commands::Start.run(Dir.pwd, %w(percheron-test))
        expect { Docker::Container.get('percheron-test_base') }.to raise_error(Docker::Error::NotFoundError)
        app1_output = Docker::Container.get('percheron-test_app1').json
        expect(app1_output['State']['Running']).to eql(true)
      end
    end
  end
end
