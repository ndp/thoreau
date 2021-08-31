module Thoreau
  module V2
    class CaseBuilder

      def initialize(context)
        @context = context
      end

      def logger
        @context.logger
      end

      def any_focused?
        @context.data.groups.count(&:focused?) > 0
      end

      def skipped_count
        return 0 unless any_focused?
        @context.data.groups.count - @context.data.groups.count(&:focused?)
      end

      def build_test_cases!
        logger.debug "build_test_cases!"

        cases = []

        @context.data
                .groups
                .select { |g| any_focused? && g.focused? || !any_focused? }
                .each do |g|

          # We have some generic "specs" for the inputs,
          # and we need to "explode" (or enumerate) the values,
          # generating a single test for each combination.
          input_sets = g.input_specs.flat_map do |input_spec|
            explode_input_specs(input_spec.keys, input_spec)
          end

          input_sets.each do |input_set|
            c = Thoreau::V2::Case.new(
              group:              g,
              input:              input_set,
              action:             @context.data.action,
              expected_output:    g.expected_output,
              expected_exception: g.expected_exception,
              asserts:            g.asserts,
              suite_context:      @context,
              logger:             logger)
            cases.push(c)
          end
        end

        cases
      end

      private

      # Expand any values that are enumerators, creating a list of
      # objects, where all the combinations of enumerated values are provided.
      def explode_input_specs(keys, input_spec)
        k = keys.pop

        value_spec = input_spec[k]
        specs      = if value_spec.is_a?(Enumerator)
                       value_spec.map do |v|
                         input_spec.merge(k => v)
                       end
                     else
                       [input_spec]
                     end

        # Are we done?
        return specs if keys.empty?

        specs.flat_map do |spec|
          explode_input_specs(keys, spec)
        end

      end

    end
  end
end
