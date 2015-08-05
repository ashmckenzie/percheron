require 'unit/spec_helper'

describe Percheron::Connection do
  let(:logger) { double('Logger') }
  let(:config) { Percheron::Config.load!('./spec/unit/support/.percheron_valid.yml') }
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
    it 'calls the instance #perform' do
      expect(subject).to receive(:perform).with(Docker::Image, :get, 'ubuntu:latest')
      subject.perform(Docker::Image, :get, 'ubuntu:latest')
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
