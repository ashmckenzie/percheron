module Percheron
  module Commands
    class Recreate < Abstract

      default_parameters!
      option('--nostart', :flag, "Don't restart unit once created", default: false)
      option('--build', :flag, '(Re)build image', default: true)
      option('--noforce', :flag, "Don't force unit (re)creation", default: false)
      option('--deep', :flag, 'Include needed units', default: false)

      def execute
        super
        opts = { unit_names: unit_names, build: build?, start: !nostart?, force: !noforce?, deep: deep? }
        runit { stack.create!(opts) }
      end
    end
  end
end
