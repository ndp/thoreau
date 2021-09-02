require_relative '../test_family'
require_relative './expanded'
require 'active_support/core_ext/array/conversions'

module Thoreau
  module DSL

    SPEC_GROUP_NAMES = %i[happy sad spec edge edges boundary corner gigo]
    # gigo = garbage in / garbage out
    #
    GROUP_PROPS         = %w[assert asserts raises output equal equals expect expects expected pending fails inputs input setup setups].sort.freeze
    PROPS_SPELL_CHECKER = DidYouMean::SpellChecker.new(dictionary: GROUP_PROPS)

    module GroupsSupport
      # Note: requires `suite_data`.
      SPEC_GROUP_NAMES.each do |sym|
        define_method sym do |*args|
          desc = args.shift if args.size > 1 && args.first.is_a?(String)
          raise "Too many arguments to #{sym}!" if args.size > 1

          spec = args.first || {}
          spec.keys
              .reject { |k| GROUP_PROPS.include? k.to_s }
              .each do |k|
            suggestions = PROPS_SPELL_CHECKER.correct(k)
            suite_data.logger.error "Ignoring unrecognized property '#{k}'."
            suite_data.logger.info "    Did you mean #{suggestions.to_sentence}?" if suggestions.size > 0
            suite_data.logger.info "    Available properties: #{GROUP_PROPS.to_sentence}"
          end

          family = TestFamily.new asserts:            spec[:assert] || spec[:asserts],
                                  desc:               desc,
                                  expected_exception: spec[:raises],
                                  expected_output:    spec[:output] || spec[:equals] || spec[:equal] || spec[:expected] || spec[:expects],
                                  failure_expected:   spec[:pending] || spec[:fails],
                                  input_specs:        [spec[:inputs] || spec[:input] || {}].flatten,
                                  kind:               sym,
                                  setups:             [spec[:setup], spec[:setups]].flatten.compact

          suite_data.add_test_family family
        end

        define_method "#{sym}!" do |*args|
          group       = self.send(sym, *args)
          group.focus = true
          group
        end
      end

      def expanded(a)
        Thoreau::DSL::Expanded.new(a)
      end

      def legacy_values(k = nil)
        :legacy # some sort of legacy marker
      end

    end

  end
end
