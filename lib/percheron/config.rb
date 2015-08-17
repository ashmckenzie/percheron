require 'yaml'

module Percheron
  class Config

    include Singleton

    DEFAULT_CONFIG_FILE = '.percheron.yml'

    # rubocop:disable Style/ClassVars
    @@file = Pathname.new(DEFAULT_CONFIG_FILE).expand_path
    # rubocop:enable Style/ClassVars

    def self.load!(file)
      instance.load!(file)
    end

    # rubocop:disable Style/ClassVars
    def load!(file)
      @@file = Pathname.new(file).expand_path
      invalidate_memoised_values!
      self
    end
    # rubocop:enable Style/ClassVars

    def self.stacks
      instance.stacks
    end

    def stacks
      @stacks ||= process_stacks!
    end

    def self.file_base_path
      instance.file_base_path
    end

    def file_base_path
      file.dirname
    end

    def self.secrets
      instance.secrets
    end

    def secrets
      secrets_file ? Hashie::Mash.new(YAML.load_file(secrets_file)) : {}
    end

    def self.userdata
      instance.userdata
    end

    def userdata
      contents.userdata || {}
    end

    def self.docker
      instance.docker
    end

    def docker
      contents.docker
    end

    private

      def file
        @@file
      end

      def secrets_file
        return unless yaml_contents.secrets_file
        File.expand_path(yaml_contents.secrets_file, file_base_path)
      end

      def invalidate_memoised_values!
        @stacks = @yaml_contents = @raw_contents = @contents = nil
      end

      # FIXME: bugs here :(
      def process_stacks!
        stacks_by_name = contents.stacks.to_hash_by_key(:name)
        scanned = scan_unit_configs(stacks_by_name)
        stacks_by_name.each do |_, stack|
          stack_units = stack.fetch(:units, []).each_with_object({}) do |unit_config, all|
            merge_or_replace(all, unit_config, scanned)
          end
          $logger.warn "No units defined for '%s' stack" % stack.name if stack_units.empty?
          stack.units = stack_units
        end
      end

      def merge_or_replace(all, config, scanned)
        if scanned[config.name]
          merge_scanned(all, config, scanned)
        else
          replace_scanned(all, config, scanned)
        end
      end

      def merge_scanned(all, config, scanned)
        all.merge!(expand_unit_config(config, scanned[config.name]))
      end

      def replace_scanned(all, config, scanned)
        match = config.fetch(:dependant_unit_names, [])
        unless (match & scanned.keys).empty?
          config.dependant_unit_names = match.map { |v| scanned[v] }.flatten
        end
        all[config.name] = config
      end

      # FIXME
      def scan_unit_configs(stacks_by_name)
        all = {}
        stacks_by_name.each do |_, stack|
          stack.fetch(:units, []).each do |unit_config|
            next if unit_config.fetch(:instances, 1) == 1
            all[unit_config.name] = 1.upto(unit_config.instances).map do |number|
              "#{unit_config.name}#{number}"
            end
          end
        end
        all
      end

      # FIXME
      def expand_unit_config(unit_config, new_unit_names)
        new_unit_names.each_with_object({}) do |new_name, all|
          temp_unit_config = unit_config.dup
          temp_unit_config.delete(:instances)
          temp_unit_config.pseudo_name = unit_config.name
          temp_unit_config.name = new_name
          all[new_name] = eval_unit_config(temp_unit_config)
        end
      end

      def eval_unit_config(unit_config)
        template = Liquid::Template.parse(unit_config.to_h.to_yaml.to_s)
        YAML.load(template.render(unit_config))
      end

      def raw_contents
        @raw_contents ||= file.read
      end

      def yaml_contents
        @yaml_contents ||= Hashie::Mash.new(YAML.load(raw_contents))
      end

      def templated_contents
        Liquid::Template.parse(raw_contents).render('secrets' => secrets)
      end

      def parsed_contents
        Hashie::Mash.new(YAML.load(templated_contents))
      end

      def contents
        @contents ||= begin
          parsed_contents.tap do |c|
            c.docker ||= {}
            c.docker.host ||= env_docker_host
            c.docker.cert_path ||= env_cert_path
            c.docker.ssl_verify_peer ||= env_ssl_verify_peer
          end
        end
      end

      def env_docker_host
        ENV['DOCKER_HOST'] || fail("Docker host not defined in '#{file}' or ENV['DOCKER_HOST']")
      end

      def env_cert_path
        ENV['DOCKER_CERT_PATH'] ? File.expand_path(ENV['DOCKER_CERT_PATH']) : nil
      end

      def env_ssl_verify_peer
        (ENV['DOCKER_TLS_VERIFY'] == 1) || true
      end
  end
end
