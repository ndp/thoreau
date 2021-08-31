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
            desc = args.shift if args.size > 1 && args.first.is_a?(String)
            raise "Too many arguments to #{sym}!" if args.size > 1

            spec  = args.first || {}
            group = SpecGroup.new asserts:            spec[:assert] || spec[:asserts],
                                  desc:               desc,
                                  expected_exception: spec[:raises],
                                  expected_output:    spec[:output] || spec[:equals] || spec[:equal] || spec[:expected],
                                  failure_expected:   spec[:pending] || spec[:fails],
                                  input_specs:        [spec[:inputs] || spec[:input] || {}].flatten,
                                  kind:               sym,
                                  setups:             [spec[:setup], spec[:setups]].flatten.compact
            logger.debug "Adding group #{group}"
            context.data.groups.push(group)
            group
          end

          define_method "#{sym}!" do |*args|
            group = self.send(sym, *args)
            group.focus = true
            group
          end
        end
      end

    end
  end
end
