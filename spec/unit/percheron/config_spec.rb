require 'unit/spec_helper'

describe Percheron::Config do
  subject { described_class.new(config_file) }

  context 'with a .percheron.yml that does not have a docker host defined' do
    let(:docker_host) { nil }
    let(:env) { { 'DOCKER_HOST' => docker_host } }

    let(:config_file) { './spec/unit/support/.percheron_valid_multiple_without_host.yml' }

    describe '#docker' do
      describe 'host' do
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

    describe '#stacks' do
      it 'returns a Hash of stack configs' do
        expect(subject.stacks).to be_a(Hash)
      end

      it 'has one stack config' do
        expect(subject.stacks.count).to eql(1)
      end
    end

    describe '#file_base_path' do
      it 'is the directory in which the file resides' do
        expect(subject.file_base_path).to eql(Pathname.new(config_file).expand_path.dirname)
      end
    end

    describe '#valid?' do
      it 'is true' do
        expect(subject.valid?).to be(true)
      end
    end
  end
end
