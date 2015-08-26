module Percheron
  module Commands
    class Main < Abstract
      subcommand 'init', 'Initialise a new .percheron.yml', Init
      subcommand 'console', '', Console
      subcommand %w(list status st), 'List stacks and its units', List
      subcommand 'start', 'Start a stack', Start
      subcommand 'stop', 'Stop a stack', Stop
      subcommand 'restart', 'Restart a stack', Restart
      subcommand %w(build rebuild), '(Re)build image(s) for a stack', Build
      subcommand 'create', 'Build image(s) and create units for a stack', Create
      subcommand 'recreate', 'Rebuild image(s) and recreate units for a stack', Recreate
      subcommand 'purge', 'Purge a stack', Purge
      subcommand 'shell', 'Shell into a unit', Shell
      subcommand 'logs', 'Show logs for a unit', Logs
      subcommand 'graph', 'Generate a stack graph', Graph
    end
  end
end
