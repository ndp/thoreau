module Thoreau
  module V2
    module DSL
      module TestCasesSupport
        # Note: requires `logger` and `context`.
        %i[happy sad spec edge edges boundary corner gigo].each do |sym|
          define_method sym do |*args|
            logger.debug "Adding test case #{sym}: #{args} self=#{self}"
            context.data.test_cases.push({ kind: sym, args: args })
          end
        end
      end

    end
  end
end
