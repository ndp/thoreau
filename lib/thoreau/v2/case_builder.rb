module Thoreau
  module V2
    class CaseBuilder

      def initialize(context)
        @context = context
      end

      def logger
        @context.logger
      end

      def build_test_cases!
        logger.debug "build_test_cases!"

        cases = []

        @context.data.groups.each do |g|
          # setup_value  = setup_block.call(temp_context)
          g.inputs.each do |input_set|
            c = Thoreau::V2::Case.new(
              group: g,
              input: input_set,
              action: @context.data.action,
              expected_output: g.expected_output,
              expected_exception: g.expected_exception,
              suite_context: @context,
              logger: logger)
            cases.push(c)
          end
        end

        cases
      end

    end

  end
end
