module Percheron
  module Commands
    class Main < Abstract
      subcommand 'list', "List stacks and it's containers", List
      subcommand 'console', 'Start a pry console session', Console
      subcommand 'start', 'Start a stack', Start
      subcommand 'stop', 'Stop a stack', Stop
      subcommand 'restart', 'Restart a stack', Restart
      subcommand 'create', 'Create a stack', Create
      subcommand 'recreate', 'Recreate a stack', Recreate
      subcommand 'purge', 'Purge a stack', Purge
    end
  end
end
