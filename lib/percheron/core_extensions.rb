module Percheron
  module CoreExtensions
    module Array
      module Extras
        def return
          result = nil
          each do |x|
            r = yield(x)
            if r
              result = r
              break
            end
          end
          result
        end

        def to_hash_by_key(key_attr)
          each_with_object({}) do |e, all|
            all[e.send(key_attr)] = e unless all[e.send(key_attr)]
          end
        end
      end
    end
  end
end

Array.include(Percheron::CoreExtensions::Array::Extras)
