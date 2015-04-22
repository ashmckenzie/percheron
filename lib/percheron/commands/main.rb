module Percheron
  module Commands
    class Main < Abstract
      subcommand %w(list status), "List stacks and it's containers", List
      subcommand 'console', 'Start a pry console session', Console
      subcommand 'start', 'Start a stack', Start
      subcommand 'stop', 'Stop a stack', Stop
      subcommand 'restart', 'Restart a stack', Restart
      subcommand 'build', 'Build images for a stack', Build
      subcommand 'create', 'Build images and create containers for a stack', Create
      subcommand 'recreate', 'Recreate a stack', Recreate
      subcommand 'purge', 'Purge a stack', Purge
      subcommand 'shell', 'Shell into a container', Shell
      subcommand 'logs', 'Show logs for a container', Logs
    end
  end
end
