require 'integration/spec_helper'

describe 'percheron' do
  before do
    $logger = double('Logger').as_null_object
    $metastore = double('Metastore').as_null_object
  end

  def cleanup!
    cleanup_containers!
    cleanup_images!
  end

  def cleanup_containers!
    %w(percheron-test_base percheron-test_app1 percheron-test_app2 percheron-test_app3 ).each do |name|
      begin
        Docker::Container.get(name).tap { |c| c.stop! && c.remove(force: true) }
      rescue Docker::Error::NotFoundError
        nil
      end
    end
  end

  def cleanup_images!
    %w(busybox:ubuntu-14.04 percheron-test_base:9.9.9 percheron-test_app1:9.9.9 percheron-test_app2:9.9.9).each do |name|
      begin
        Docker::Image.get(name).tap { |i| i.remove(force: true) }
      rescue Docker::Error::NotFoundError
        nil
      end
    end
  end

  before(:all) do
    Dir.chdir('./spec/integration/support')
    cleanup!
  end

  after do
    $logger = $metastore = nil
    cleanup!
  end

  describe 'list' do
    it 'displays a terminal table' do
      expect { Percheron::Commands::List.run(Dir.pwd, %w(percheron-test)) }.to output(%r{base      |    | n/a}).to_stdout
    end
  end

  describe 'build' do
    context 'for just the base container' do
      it 'builds an image' do
        Percheron::Commands::Build.run(Dir.pwd, %w(percheron-test base))
        output = Docker::Image.get('percheron-test_base:9.9.9').json
        expect(output['Author']).to eql('ash@the-rebellion.net')
      end
    end

    context 'for just the app1 container' do
      it 'builds an image' do
        Percheron::Commands::Build.run(Dir.pwd, %w(percheron-test app1))
        output = Docker::Image.get('percheron-test_app1:9.9.9').json
        expect(output['Config']['Cmd']).to eql([ 'sh', '-c', "while true; do date ; echo 'hello from percheron'; done" ])
      end
    end

    context 'for all containers' do
      it 'builds base and app1 images' do
        Percheron::Commands::Build.run(Dir.pwd, %w(percheron-test))
        base_output = Docker::Image.get('percheron-test_base:9.9.9').json
        app1_output = Docker::Image.get('percheron-test_app1:9.9.9').json
        expect(base_output['Author']).to eql('ash@the-rebellion.net')
        expect(app1_output['Config']['Cmd']).to eql([ 'sh', '-c', "while true; do date ; echo 'hello from percheron'; done" ])
      end
    end
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

  describe 'recreate' do
    context 'for just the base container' do
      it 'cannot recreate a container as not startable' do
        Percheron::Commands::Create.run(Dir.pwd, %w(percheron-test base))
        Percheron::Commands::Recreate.run(Dir.pwd, %w(percheron-test base))
        expect { Docker::Container.get('percheron-test_base') }.to raise_error(Docker::Error::NotFoundError)
      end
    end

    context 'for just the app1 container' do
      it 'recreates a container' do
        Percheron::Commands::Create.run(Dir.pwd, %w(percheron-test app1))
        Percheron::Commands::Recreate.run(Dir.pwd, %w(percheron-test app1))
        output = Docker::Container.get('percheron-test_app1').json
        expect(output['Config']['Cmd']).to eql([ 'sh', '-c', "while true; do date ; echo 'hello from percheron'; done" ])
      end
    end

    context 'for all containers' do
      it 'creates just the app1 container' do
        Percheron::Commands::Create.run(Dir.pwd, %w(percheron-test))
        Percheron::Commands::Recreate.run(Dir.pwd, %w(percheron-test))
        expect { Docker::Container.get('percheron-test_base') }.to raise_error(Docker::Error::NotFoundError)
        app1_output = Docker::Container.get('percheron-test_app1').json
        expect(app1_output['Config']['Cmd']).to eql([ 'sh', '-c', "while true; do date ; echo 'hello from percheron'; done" ])
      end
    end
  end

  describe 'start' do
    context 'for just the base container' do
      it 'cannot create a container as not startable' do
        Percheron::Commands::Start.run(Dir.pwd, %w(percheron-test base))
        expect { Docker::Container.get('percheron-test_base') }.to raise_error(Docker::Error::NotFoundError)
      end
    end

    context 'for just the app1 container' do
      it 'starts the container' do
        Percheron::Commands::Start.run(Dir.pwd, %w(percheron-test app1))
        output = Docker::Container.get('percheron-test_app1').json
        expect(output['State']['Running']).to eql(true)
      end
    end

    context 'for just the app2 container' do
      it 'starts the container' do
        Percheron::Commands::Start.run(Dir.pwd, %w(percheron-test app2))
        output = Docker::Container.get('percheron-test_app2').json
        expect(output['State']['Running']).to eql(true)
      end
    end

    context 'for just the app3 container' do
      it 'starts the container' do
        Percheron::Commands::Start.run(Dir.pwd, %w(percheron-test app3))
        output = Docker::Container.get('percheron-test_app3').json
        expect(output['State']['Running']).to eql(true)
      end
    end

    context 'for all containers' do
      it 'starts just the app1 container' do
        Percheron::Commands::Start.run(Dir.pwd, %w(percheron-test))
        expect { Docker::Container.get('percheron-test_base') }.to raise_error(Docker::Error::NotFoundError)
        app1_output = Docker::Container.get('percheron-test_app1').json
        expect(app1_output['State']['Running']).to eql(true)
      end
    end
  end

  describe 'stop' do
    context 'for just the base container' do
      it 'cannot create a container as not startable' do
        Percheron::Commands::Start.run(Dir.pwd, %w(percheron-test base))
        Percheron::Commands::Stop.run(Dir.pwd, %w(percheron-test base))
        expect { Docker::Container.get('percheron-test_base') }.to raise_error(Docker::Error::NotFoundError)
      end
    end

    context 'for just the app1 container' do
      it 'stop the container' do
        Percheron::Commands::Start.run(Dir.pwd, %w(percheron-test app1))
        Percheron::Commands::Stop.run(Dir.pwd, %w(percheron-test app1))
        output = Docker::Container.get('percheron-test_app1').json
        expect(output['State']['Running']).to eql(false)
      end
    end

    context 'for all containers' do
      it 'stop just the app1 container' do
        Percheron::Commands::Start.run(Dir.pwd, %w(percheron-test))
        Percheron::Commands::Stop.run(Dir.pwd, %w(percheron-test))
        expect { Docker::Container.get('percheron-test_base') }.to raise_error(Docker::Error::NotFoundError)
        app1_output = Docker::Container.get('percheron-test_app1').json
        expect(app1_output['State']['Running']).to eql(false)
      end
    end
  end

  describe 'restart' do
    context 'for just the base container' do
      it 'cannot create a container as not startable' do
        Percheron::Commands::Start.run(Dir.pwd, %w(percheron-test base))
        Percheron::Commands::Restart.run(Dir.pwd, %w(percheron-test base))
        expect { Docker::Container.get('percheron-test_base').json }.to raise_error(Docker::Error::NotFoundError)
      end
    end

    context 'for just the app1 container' do
      it 'restarts the container' do
        Percheron::Commands::Start.run(Dir.pwd, %w(percheron-test app1))
        Percheron::Commands::Restart.run(Dir.pwd, %w(percheron-test app1))
        output = Docker::Container.get('percheron-test_app1').json
        expect(output['State']['Running']).to eql(true)
      end
    end

    context 'for all containers' do
      it 'restarts just the app1 container' do
        Percheron::Commands::Start.run(Dir.pwd, %w(percheron-test))
        Percheron::Commands::Restart.run(Dir.pwd, %w(percheron-test))
        expect { Docker::Container.get('percheron-test_base').json }.to raise_error(Docker::Error::NotFoundError)
        app1_output = Docker::Container.get('percheron-test_app1').json
        expect(app1_output['State']['Running']).to eql(true)
      end
    end
  end

  describe 'purge' do
    context 'for just the app1 container' do
      it 'purges app1 images and containers' do
        Percheron::Commands::Create.run(Dir.pwd, %w(percheron-test app1))
        Percheron::Commands::Purge.run(Dir.pwd, %w(percheron-test app1))
        expect { Docker::Image.get('percheron-test_app1:9.9.9').json }.to raise_error(Docker::Error::NotFoundError)
        expect { Docker::Container.get('percheron-test_app1').json }.to raise_error(Docker::Error::NotFoundError)
      end
    end

    context 'for all containers' do
      it 'purges base, app1 images and containers' do
        Percheron::Commands::Create.run(Dir.pwd, %w(percheron-test))
        Percheron::Commands::Purge.run(Dir.pwd, %w(percheron-test))

        expect { Docker::Image.get('percheron-test_base:9.9.9').json }.to raise_error(Docker::Error::NotFoundError)
        expect { Docker::Container.get('percheron-test_base').json }.to raise_error(Docker::Error::NotFoundError)

        expect { Docker::Image.get('percheron-test_app1:9.9.9').json }.to raise_error(Docker::Error::NotFoundError)
        expect { Docker::Container.get('percheron-test_app1').json }.to raise_error(Docker::Error::NotFoundError)
      end
    end
  end
end
