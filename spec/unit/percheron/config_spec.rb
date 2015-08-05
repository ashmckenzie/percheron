require 'unit/spec_helper'

describe Percheron::Config do
  subject do
    described_class.load!(config_file)
    described_class
  end

  describe '.secrets' do
    context 'with a .percheron.yml that does not have secrets' do
      let(:config_file) { './spec/unit/support/.percheron_valid_multiple.yml' }

      it 'is an empty Hash' do
        expect(subject.secrets).to eql({})
      end
    end

    context 'with a .percheron.yml that has secrets' do
      let(:config_file) { './spec/unit/support/.percheron_valid_multiple_with_secrets_and_userdata.yml' }

      it 'exposes them' do
        expect(subject.secrets).to eql('very' => 'secret')
      end
    end
  end

  describe '.userdata' do
    context 'with a .percheron.yml that does not have userdata' do
      let(:config_file) { './spec/unit/support/.percheron_valid_multiple.yml' }

      it 'is an empty Hash' do
        expect(subject.userdata).to eql({})
      end
    end

    context 'with a .percheron.yml that has userdata' do
      let(:config_file) { './spec/unit/support/.percheron_valid_multiple_with_secrets_and_userdata.yml' }

      it 'exposes them' do
        expect(subject.userdata).to eql('key' => 'value')
      end
    end
  end

  context 'with a .percheron.yml that does not have a docker host defined' do
    let(:docker_host) { nil }
    let(:env) { { 'DOCKER_HOST' => docker_host } }

    let(:config_file) { './spec/unit/support/.percheron_valid_multiple_without_host.yml' }

    describe '.docker' do
      describe '.host' do
        context "with no ENV['DOCKER_HOST'] defined" do
          it 'raises exception' do
            expect { with_modified_env(env) { subject.docker.host } }.to raise_error(/Docker host not defined/)
          end
        end

        context "with a ENV['DOCKER_HOST'] defined" do
          let(:docker_host) { 'localhost:2735' }

          it 'raises exception' do
            with_modified_env(env) do
              expect(subject.docker.host).to eql('localhost:2735')
            end
          end
        end
      end
    end
  end

  context 'with a .percheron.yml that has a docker host defined' do
    let(:config_file) { './spec/unit/support/.percheron_valid_multiple.yml' }

    describe '.stacks' do
      it 'returns a Hash of stack configs' do
        expect(subject.stacks).to be_a(Hash)
      end

      it 'has one stack config' do
        expect(subject.stacks.count).to eql(1)
      end
    end

    describe '.file_base_path' do
      it 'is the directory in which the file resides' do
        expect(subject.file_base_path).to eql(Pathname.new(config_file).expand_path.dirname)
      end
    end
  end
end
