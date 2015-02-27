require 'yaml'

module Percheron
  class Config

    extend Forwardable

    def_delegators :contents, :docker

    def initialize(file)
      @file = Pathname.new(file).expand_path
      valid?
    end

    def stacks
      contents.stacks.inject({}) do |all, stack_config|
        all[stack_config.name] = stack_config unless all[stack_config.name]
        all
      end
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

  end
end
