require_relative '../spec_group'

module Thoreau
  module V2
    module DSL

      SPEC_GROUP_NAMES = %i[happy sad spec edge edges boundary corner gigo]
      # gigo = garbage in / garbage out

      module GroupsSupport
        # Note: requires `logger` and `context`.
        SPEC_GROUP_NAMES.each do |sym|
          define_method sym do |*args|
            if args.size > 1 && args.first.is_a?(String)
              desc = args.shift
            end
            raise "Too many arguments to #{sym}!" if args.size > 1
            group = SpecGroup.new(kind: sym, desc: desc, spec: args.first || {})
            logger.debug "Adding group #{group}"
            context.data.groups.push(group)
          end
        end
      end

    end
  end
end
