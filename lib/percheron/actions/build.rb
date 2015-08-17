module Percheron
  module Actions
    class Build
      include Base

      def initialize(unit, usecache: true, forcerm: false, exec_scripts: true)
        @unit = unit
        @usecache = usecache
        @forcerm = forcerm
        @exec_scripts = exec_scripts
      end

      def execute!
        results = []
        if unit.buildable?
          results << write_out_temp_dockerfile!
          results << build!
        end
        results.compact.empty? ? nil : unit
      end

      private

        attr_reader :unit, :usecache, :forcerm, :exec_scripts
        alias_method :usecache?, :usecache
        alias_method :forcerm?, :forcerm
        alias_method :exec_scripts?, :exec_scripts

        def options
          {
            'dockerfile'  => dockerfile,
            't'           => unit.image_name,
            'forcerm'     => forcerm?,
            'nocache'     => !usecache?
          }
        end

        def dockerfile
          temp_dockerfile.basename.to_s
        end

        def temp_dockerfile
          @temp_dockerfile ||= Pathname.new(temp_dockerfile_name)
        end

        def temp_dockerfile_name
          @temp_dockerfile_name ||= begin
            '%s/%s.%s' % [
              unit.dockerfile.expand_path.dirname.to_s,
              unit.dockerfile.basename.to_s,
              SecureRandom.urlsafe_base64
            ]
          end
        end

        def write_out_temp_dockerfile!
          options = { 'secrets' => Config.secrets, 'userdata' => Config.userdata }
          content = Liquid::Template.parse(unit.dockerfile.read).render(options)
          File.open(temp_dockerfile, 'w') { |f| f.write(content) }
        end

        def remove_temp_dockerfile!
          temp_dockerfile.delete
        end

        def build!
          in_working_directory(base_dir) do
            execute_pre_build_scripts!
            $logger.info "Building '#{unit.image_name}' image"
            Connection.perform(Docker::Image, :build_from_dir, base_dir, options) do |out|
              $logger.debug '%s' % [ out.strip ]
            end
          end
        ensure
          remove_temp_dockerfile!
        end

        def execute_pre_build_scripts!
          return nil if !exec_scripts? && unit.pre_build_scripts.empty?
          ExecLocal.new(unit, unit.pre_build_scripts, 'PRE build').execute!
        end
    end
  end
end
