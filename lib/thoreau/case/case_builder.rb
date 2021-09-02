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

      def initialize(test_families, suite_data)
        @test_families = test_families
        @suite_data    = suite_data
      end

      def logger
        @suite_data.logger
      end

      def any_focused?
        @test_families.count(&:focused?) > 0
      end

      def skipped_count
        return 0 unless any_focused?
        @test_families.count - @test_families.count(&:focused?)
      end

      def build_test_cases!
        logger.debug "build_test_cases!"

        @test_families
          .select { |g| any_focused? && g.focused? || !any_focused? }
          .flat_map do |g|
          build_group_cases g
        end
      end

      private

      def setup_key_to_inputs key
        setup = @suite_data.setups[key.to_s]
        raise "Unrecognized setup context '#{key}'. Available: #{@suite_data.setups.keys.to_sentence}" if setup.nil?

        return setup.values if setup.block.nil?

        result = Class.new.new.instance_eval(&setup.block)
        logger.error "Setup #{key} did not return a hash object" unless result.is_a?(Hash)
        result
      end

      def build_group_cases g
        # We have "specs" for the inputs. These may be actual
        # values, or they may be enumerables that need to execute.
        # So we need to "explode" (or enumerate) the values,
        # generating a single test for each combination.
        #
        setup_values = g.setups
                        .map { |key| setup_key_to_inputs key }
                        .reduce(Hash.new) { |m, h| m.merge(h) }

        input_sets = g.input_specs
                      .map { |is| setup_values.merge(is) }
                      .flat_map do |input_spec|
          explode_input_specs(input_spec.keys, input_spec)
        end

        input_sets.map do |input_set|
          Thoreau::TestCase.new(
            group:              g,
            input:              input_set,
            action_block:       @suite_data.action_block,
            expected_output:    g.expected_output,
            expected_exception: g.expected_exception,
            asserts:            g.asserts,
            logger:             logger)
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
