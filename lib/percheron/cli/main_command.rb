module Percheron
  module CLI
      subcommand 'list', 'List stacks and containers', ListCommand
    class MainCommand < Clamp::Command
    end
  end
end
