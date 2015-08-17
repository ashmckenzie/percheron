module Percheron
  module Commands
    class Create < Abstract

      default_parameters!
      option('--start', :flag, '(Re)start unit once created', default: true)
      option('--build', :flag, '(Re)build image', default: true)
      option('--force', :flag, 'Force unit (re)creation', default: false)

      def execute
        super
        stack.create!(unit_names: unit_names, build: build?, start: start?, force: force?)
      end
    end
  end
end
