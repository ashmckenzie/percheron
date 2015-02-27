module Percheron
  module CLI
    class MainCommand < AbstractCommand
      subcommand 'list', "List stacks and it's containers", ListCommand
      subcommand 'start', 'Start a stack', StartCommand
    end
  end
end
