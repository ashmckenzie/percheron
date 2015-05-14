module Percheron
  module Commands
    class Main < Abstract
      subcommand %w(list status), "List stacks and it's units", List
      subcommand 'console', 'Start a pry console session', Console
      subcommand 'start', 'Start a stack', Start
      subcommand 'stop', 'Stop a stack', Stop
      subcommand 'restart', 'Restart a stack', Restart
      subcommand 'build', 'Build images for a stack', Build
      subcommand 'create', 'Build images and create units for a stack', Create
      subcommand 'recreate', 'Recreate a stack', Recreate
      subcommand 'purge', 'Purge a stack', Purge
      subcommand 'shell', 'Shell into a unit', Shell
      subcommand 'logs', 'Show logs for a unit', Logs
    end
  end
end
