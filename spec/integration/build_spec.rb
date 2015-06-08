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

  describe 'build' do
    context 'for just the base unit' do
      it 'builds an image' do
        Percheron::Commands::Build.run(Dir.pwd, %w(percheron-common base))
        output = Docker::Image.get('percheron-common_base:9.9.9').json
        expect(output['Author']).to eql('ash@the-rebellion.net')
      end
    end

    context 'for just the app1 unit' do
      it 'builds an image' do
        Percheron::Commands::Build.run(Dir.pwd, %w(percheron-test app1))
        output = Docker::Image.get('percheron-test_app1:9.9.9').json
        expect(output['Config']['Cmd']).to eql([ 'sh', '-c', "while true; do date ; echo 'hello from percheron'; done" ])
      end
    end

    context 'for just the app2 unit' do
      it 'builds an image' do
        Percheron::Commands::Build.run(Dir.pwd, %w(percheron-test app2))
        output = Docker::Image.get('percheron-test_app2:9.9.9').json
        expect(output['Config']['Cmd']).to eql([ 'sh', '-c', "while true; do date ; echo 'hello from percheron'; done" ])
      end
    end

    context 'for all units' do
      it 'builds base and app1 images' do
        Percheron::Commands::Build.run(Dir.pwd, %w(percheron-test))
        base_output = Docker::Image.get('percheron-common_base:9.9.9').json
        app1_output = Docker::Image.get('percheron-test_app1:9.9.9').json
        app2_output = Docker::Image.get('percheron-test_app2:9.9.9').json
        expect(base_output['Author']).to eql('ash@the-rebellion.net')
        expect(app1_output['Config']['Cmd']).to eql([ 'sh', '-c', "while true; do date ; echo 'hello from percheron'; done" ])
        expect(app2_output['Config']['Cmd']).to eql([ 'sh', '-c', "while true; do date ; echo 'hello from percheron'; done" ])
      end
    end
  end
end
