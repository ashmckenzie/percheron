module Percheron
  module Commands
    class Build < Abstract

      default_parameters!
      option('--usecache', :flag, 'Use image cache', default: true)
      option('--forcerm', :flag, 'Force removal of intermediate containers', default: false)

      def execute
        super
        stack.build!(unit_names: unit_names, usecache: usecache?, forcerm: forcerm?)
      end
    end
  end
end
