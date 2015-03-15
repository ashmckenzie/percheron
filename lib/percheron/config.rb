require 'yaml'

module Percheron
  class Config

    extend Forwardable

    def_delegators :contents, :docker

    def initialize(file)
      @file = Pathname.new(file).expand_path
      # valid?
      docker_setup!
      self
    end

    def stacks
      contents.stacks.to_hash_by_key(:name)
    end

    def file_base_path
      file.dirname
    end

    def valid?
      Validators::Config.new(file).valid?
    end

    private

      attr_reader :file

      def contents
        Hashie::Mash.new(YAML.load_file(file))
      end

      def docker_setup!
        Percheron::DockerConnection.new(self).setup!
      end

  end
end
