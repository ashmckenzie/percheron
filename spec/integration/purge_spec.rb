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

  describe 'purge' do
    context 'for just the app1 unit' do
      it 'purges app1 images and units' do
        Percheron::Commands::Create.run(Dir.pwd, %w(percheron-test app1))
        Percheron::Commands::Purge.run(Dir.pwd, %w(--force percheron-test app1))
        expect { Docker::Image.get('percheron-test_app1:9.9.9').json }.to raise_error(Docker::Error::NotFoundError)
        expect { Docker::Container.get('percheron-test_app1').json }.to raise_error(Docker::Error::NotFoundError)
      end
    end

    context 'for all units' do
      it 'purges base, app1 images and units' do
        Percheron::Commands::Create.run(Dir.pwd, %w(percheron-test))
        Percheron::Commands::Purge.run(Dir.pwd, %w(--force percheron-common percheron-test))
        expect { Docker::Image.get('percheron-common_base:9.9.9').json }.to raise_error(Docker::Error::NotFoundError)
        expect { Docker::Container.get('percheron-common_base').json }.to raise_error(Docker::Error::NotFoundError)
        expect { Docker::Image.get('percheron-test_app1:9.9.9').json }.to raise_error(Docker::Error::NotFoundError)
        expect { Docker::Container.get('percheron-test_app1').json }.to raise_error(Docker::Error::NotFoundError)
      end
    end
  end
end
