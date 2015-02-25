module Percheron
  module ConfigDelegator

    def def_config_item_with_default(config, default, *symbols)
      symbols.each do |symbol|
        define_method(symbol) do
          send(config).fetch(symbol, default)
        end
      end
    end
  end
end
