require 'integration/spec_helper'

describe 'percheron' do
  before do
    $logger = double('Logger').as_null_object
    $metastore = double('Metastore').as_null_object
  end

  describe 'restart' do
    context 'for just the base unit' do
      it 'cannot create a unit as not startable' do
        Percheron::Commands::Start.run(Dir.pwd, %w(percheron-test base))
        Percheron::Commands::Restart.run(Dir.pwd, %w(percheron-test base))
        expect { Docker::Container.get('percheron-test_base').json }.to raise_error(Docker::Error::NotFoundError)
      end
    end

    context 'for just the app1 unit' do
      it 'restarts the unit' do
        Percheron::Commands::Start.run(Dir.pwd, %w(percheron-test app1))
        Percheron::Commands::Restart.run(Dir.pwd, %w(percheron-test app1))
        output = Docker::Container.get('percheron-test_app1').json
        expect(output['State']['Running']).to eql(true)
      end
    end

    context 'for all units' do
      it 'restarts just the app1 unit' do
        Percheron::Commands::Start.run(Dir.pwd, %w(percheron-test))
        Percheron::Commands::Restart.run(Dir.pwd, %w(percheron-test))
        expect { Docker::Container.get('percheron-test_base').json }.to raise_error(Docker::Error::NotFoundError)
        app1_output = Docker::Container.get('percheron-test_app1').json
        expect(app1_output['State']['Running']).to eql(true)
      end
    end
  end
end
