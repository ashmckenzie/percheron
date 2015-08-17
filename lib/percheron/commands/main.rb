module Percheron
  module Commands
    class Main < Abstract
      subcommand %w(list status), 'List stacks and its units', List
      subcommand 'console', '', Console
      subcommand 'start', 'Start a stack', Start
      subcommand 'stop', 'Stop a stack', Stop
      subcommand 'restart', 'Restart a stack', Restart
      subcommand %w(build rebuild), '(Re)build image(s) for a stack', Build
      subcommand %w(create recreate), '(Re)build image(s) and (re)create units for a stack', Create
      subcommand 'purge', 'Purge a stack', Purge
      subcommand 'shell', 'Shell into a unit', Shell
      subcommand 'logs', 'Show logs for a unit', Logs
      subcommand 'graph', 'Generate a stack graph', Graph
    end
  end
end
