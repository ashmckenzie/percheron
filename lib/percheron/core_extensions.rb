module Percheron
  module CoreExtensions
    module Array
      module Returning
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
      end
    end
  end
end

Array.include(Percheron::CoreExtensions::Array::Returning)
