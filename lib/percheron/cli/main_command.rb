module Percheron
  module CLI
    class MainCommand < AbstractCommand
      subcommand 'list', "List stacks and it's containers", ListCommand
      subcommand 'console', 'Start a pry console session', ConsoleCommand
      subcommand 'start', 'Start a stack', StartCommand
      subcommand 'stop', 'Stop a stack', StopCommand
      subcommand 'restart', 'Restart a stack', RestartCommand
      subcommand 'create', 'Create a stack', CreateCommand
      subcommand 'recreate', 'Recreate a stack', RecreateCommand
      subcommand 'purge', 'Purge a stack', PurgeCommand
    end
  end
end
