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
          logger.debug "Processing #{g}"
          # setup_value  = setup_block.call(temp_context)
          g.inputs.each do |input_set|
            c = Thoreau::V2::Case.new(
              g,
              input_set,
              @context.data.action,
              g.expected_output,
              g.expected_exception)
            cases.push(c)
          end
        end

        cases
      end

    end

  end
end
