module Percheron
  module Commands
    class Build < Abstract

      default_parameters!
      option('--forcerm', :flag, 'force removal of intermediate containers', default: false)

      def execute
        super
        stack.build!(unit_names: unit_names, forcerm: forcerm?)
      end
    end
  end
end
