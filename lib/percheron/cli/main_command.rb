module Percheron
  module CLI
    class MainCommand < AbstractCommand
      subcommand 'list', 'List stacks and containers', ListCommand
    end
  end
end
