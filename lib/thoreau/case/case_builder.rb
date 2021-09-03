module Thoreau
  module Case
    # Build test cases.
    #
    # It is responsible for:
    # - building an list of Test::Case objects based
    #   on the groups provided.
    # - expanding input specs in the groups into multiple cases
    # - skipping unfocused tests, if any are focused
    # - returning a count of those skipped
    class CaseBuilder

      include Logging

      def initialize(action_block:, test_families:, appendix:)
        @test_families = test_families
        @action_block  = action_block
        @appendix      = appendix
      end

      def any_focused?
        @test_families.count(&:focused?) > 0
      end

      def skipped_count
        return 0 unless any_focused?
        @test_families.count - @test_families.count(&:focused?)
      end

      def build_test_cases!
        logger.debug "build_test_cases! (#{@test_families.size} families)"

        @test_families
          .select { |fam| any_focused? && fam.focused? || !any_focused? }
          .flat_map { |fam| build_family_cases fam }
      end

      private

      def setup_key_to_inputs key
        setup = @appendix.setups[key.to_s]
        raise "Unrecognized setup context '#{key}'. Available: #{@appendix.setups.keys.to_sentence}" if setup.nil?

        return setup.values if setup.block.nil?

        result = Class.new.new.instance_eval(&setup.block)
        logger.error "Setup #{key} did not return a hash object" unless result.is_a?(Hash)
        result
      end

      def build_family_cases fam
        # We have "specs" for the inputs. These may be actual
        # values, or they may be enumerables that need to execute.
        # So we need to "explode" (or enumerate) the values,
        # generating a single test for each combination.
        #
        setup_values = fam.setups
                          .map { |key| setup_key_to_inputs key }
                          .reduce(Hash.new) { |m, h| m.merge(h) }

        input_sets = fam.input_specs
                        .map { |is| setup_values.merge(is) }
                        .flat_map do |input_spec|
          explode_input_specs(input_spec.keys, input_spec)
        end
        logger.debug(">> input_specs" + fam.input_specs.map(&:to_s).join('/'))
        logger.debug("build family cases '#{fam.desc}', #{setup_values.size} setups, #{input_sets.size} input sets")

        input_sets.map do |input_set|
          expectation = Outcome.new output:    fam.expected_output,
                                    exception: fam.expected_exception

          Thoreau::TestCase.new family_desc:    "#{fam.kind.to_s.ljust(8)}  #{fam.desc}",
                                input:          input_set,
                                action_block:   @action_block,
                                expectation:    expectation,
                                asserts:        fam.asserts,
                                expect_failure: fam.failure_expected?
        end

      end

      # Expand any values that are enumerators (Thoreau::DSL::Expanded),
      # creating a list of objects, where all the combinations
      # of enumerated values are present.
      def explode_input_specs(keys, input_spec)
        k = keys.pop

        value_spec = input_spec[k]
        specs      = if value_spec.is_a?(Thoreau::DSL::Expanded)
                       value_spec.map do |v|
                         input_spec.merge(k => v)
                       end
                     else
                       [input_spec]
                     end

        # Are we done?
        return specs if keys.empty?

        specs.flat_map do |spec|
          explode_input_specs(keys, spec) # recurse!
        end

      end

    end
  end
end
