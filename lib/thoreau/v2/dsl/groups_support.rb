module Thoreau
  module V2
    module DSL
      module GroupsSupport
        # Note: requires `logger` and `context`.
        %i[happy sad spec edge edges boundary corner gigo].each do |sym|
          define_method sym do |*args|
            logger.debug "Adding group #{sym}: #{args} self=#{self}"
            context.data.groups.push({ kind: sym, args: args })
          end
        end
      end

    end
  end
end
