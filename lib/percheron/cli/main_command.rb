module Percheron
  module CLI
    class MainCommand < Clamp::Command
      subcommand 'list', "List stacks and it's containers", ListCommand
      subcommand 'start', 'Start a stack', StartCommand
    end
  end
end
