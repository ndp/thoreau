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

        @context.data.groups.each do |test_case|
          logger.debug "Processing #{test_case}"
          spec = test_case[:args].first || {}
          # setup_value  = setup_block.call(temp_context)
          inputs = spec[:inputs] || spec[:input] || {}
          [inputs].flatten.each do |input_set|
            c = Thoreau::V2::Case.new(test_case[:kind], input_set, @context.data.action, spec[:output], spec[:raises])
            cases.push(c)
          end
        end

        cases
      end

    end

  end
end
