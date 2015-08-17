module Percheron
  module Commands
    class Main < Abstract
      subcommand %w(list status), 'List stacks and its units', List
      subcommand 'console', 'Start a pry console session', Console
      subcommand 'start', 'Start a stack', Start
      subcommand 'stop', 'Stop a stack', Stop
      subcommand 'restart', 'Restart a stack', Restart
      subcommand 'build', 'Build images for a stack', Build
      subcommand 'create', 'Build images and create units for a stack', Create
      subcommand 'purge', 'Purge a stack', Purge
      subcommand 'shell', 'Shell into a unit', Shell
      subcommand 'logs', 'Show logs for a unit', Logs
      subcommand 'graph', 'Generate a stack graph', Graph
    end
  end
end
