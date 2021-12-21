require_relative '../../model/test_family'
require_relative '../expanded'
require_relative '../../service/util'
require 'active_support/core_ext/array/conversions'

module Thoreau
  module DSL
    module Context

      SPEC_FAMILY_NAMES = %i[happy sad spec test edge edges boundary corner gigo]
      # gigo = garbage in / garbage out
      #
      PROPS               = {
        asserts:            %i[assert asserts post post_condition],
        expected_exception: %i[raises],
        expected_output:    %i[equals equal expected expect expects output],
        failure_expected:   %i[fails pending],
        input_specs:        %i[input inputs],
        setups:             %i[setup setups assemble]
      }
      ALL_PROPS           = PROPS.values.flatten.map(&:to_s)
      PROPS_SPELL_CHECKER = DidYouMean::SpellChecker.new(dictionary: ALL_PROPS)

      module Clan

        # Note: requires `@test_clan_model`.

        def action(&block)
          logger.debug "   + Adding subject block"
          @test_clan_model.action_block = block
        end

        alias act action
        alias testing action
        alias subject action

        def self.def_family_methods_for(sym)
          define_method sym do |*args|
            desc = args.shift if args.size > 1 && args.first.is_a?(String)
            raise "Too many arguments to #{sym}!" if args.size > 1

            spec = args.first&.stringify_keys || {}
            spec.keys
                .reject { |k| ALL_PROPS.include? k }
                .each do |k|
              suggestions = PROPS_SPELL_CHECKER.correct(k)
              logger.error "Ignoring unrecognized property '#{k}'."
              logger.info "    Did you mean #{suggestions.to_sentence}?" if suggestions.size > 0
              logger.info "    Available properties: #{ALL_PROPS.to_sentence}"
            end

            params = HashUtil.normalize_props(spec.symbolize_keys, PROPS).tap { |props|
              # These two props are easier to deal with downstream as empty arrays
              props[:input_specs] = [props[:input_specs]].flatten.compact
              props[:setups]      = [props[:setups]].flatten.compact
            }.merge kind: sym,
                    desc: desc

            family = Model::TestFamily.new **params

            yield family if block_given?

            logger.debug "   * Created new family #{params.inspect}"
            @test_clan_model.add_test_family family
          end

          define_method "#{sym}!" do |*args|
            family       = self.send(sym, *args)
            family.focus = true
            family
          end
        end

        SPEC_FAMILY_NAMES.each do |sym|
          def_family_methods_for sym
        end

        def_family_methods_for :legacy do |r|
          r.use_legacy_snapshot = true
        end

        alias legacy_spec legacy
        alias legacy_test legacy
        alias legacy_code legacy
        alias legacy_spec! legacy!
        alias legacy_test! legacy!
        alias legacy_code! legacy!

        def expanded(a)
          Thoreau::DSL::Expanded.new(a)
        end

      end
    end
  end
end
