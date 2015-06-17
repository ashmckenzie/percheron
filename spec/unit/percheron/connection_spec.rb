require 'unit/spec_helper'

describe Percheron::Connection do
  let(:logger) { double('Logger') }
  let(:config) { Percheron::Config.new('./spec/unit/support/.percheron_valid.yml') }
  let(:expected_url) { 'https://127.0.0.1:2376' }

  subject { described_class.load!(config) }

  before(:each) { Singleton.__init__(described_class) }

  before do
    $logger = logger
  end

  after do
    $logger = nil
  end

  describe '.perform' do
    context 'when an exception is thrown' do
      before do
        expect(Docker::Image).to receive(:get).with('ubuntu:latest').and_raise(exception)
      end

      context 'when a Docker::Error::NotFoundError exception is thrown' do
        let(:exception) { Docker::Error::NotFoundError }

        it 'raises an Errors::ConnectionException exception' do
          expect { described_class.perform(Docker::Image, :get, 'ubuntu:latest') }.to raise_error(Percheron::Errors::ConnectionException)
        end
      end

      context 'when a Excon::Errors::SocketError exception is thrown' do
        let(:exception) { Excon::Errors::SocketError.new(StandardError.new) }

        it 'raises an Errors::ConnectionException exception' do
          expect { described_class.perform(Docker::Image, :get, 'ubuntu:latest') }.to raise_error(Percheron::Errors::ConnectionException)
        end
      end

      context 'when an unknown exception is thrown' do
        let(:exception) { StandardError }

        it 'raises an Errors::ConnectionException exception' do
          expect(logger).to receive(:debug).with('Docker::Image.get(["ubuntu:latest"]) - #<StandardError: StandardError>')
          expect { described_class.perform(Docker::Image, :get, 'ubuntu:latest') }.to raise_error(exception)
        end
      end
    end

    context 'when no exception is thrown' do
      it 'calls the instance #perform' do
        expect(subject).to receive(:perform).with(Docker::Image, :get, 'ubuntu:latest')
        described_class.perform(Docker::Image, :get, 'ubuntu:latest')
      end
    end
  end

  describe '#setup!' do
    context "when ENV['DOCKER_CERT_PATH'] is defined" do
      let(:expected_options) { { client_cert: '/tmp/cert.pem', client_key: '/tmp/key.pem', ssl_ca_file: '/tmp/ca.pem', scheme: 'https', read_timeout: 300, connect_timeout: 5 } }

      it 'sets Docker url' do
        subject.setup!
        expect(Docker.url).to eql(expected_url)
      end

      it 'sets Docker options' do
        with_modified_env(DOCKER_CERT_PATH: '/tmp') do
          subject.setup!
        end
        expect(Docker.options).to eql(expected_options)
      end
    end

    context "when ENV['DOCKER_CERT_PATH'] is not defined" do
      let(:docker_cert_path) { nil }
      let(:expected_options) { { read_timeout: 300, connect_timeout: 5 } }

      it 'sets Docker url' do
        subject.setup!
        expect(Docker.url).to eql(expected_url)
      end

      it 'sets Docker options' do
        with_modified_env(DOCKER_CERT_PATH: nil) do
          subject.setup!
        end
        expect(Docker.options).to eql(expected_options)
      end
    end
  end
end
