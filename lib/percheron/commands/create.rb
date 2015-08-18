module Percheron
  module Commands
    class Create < Abstract

      default_parameters!
      option('--start', :flag, '(Re)start unit once created', default: true)
      option('--build', :flag, '(Re)build image', default: true)
      option('--deep', :flag, 'Include needed units', default: false)
      option('--force', :flag, 'Force unit (re)creation', default: false)

      def execute
        super
        opts = { unit_names: unit_names, build: build?, start: start?, deep: deep?, force: force? }
        runit { stack.create!(opts) }
      end
    end
  end
end
