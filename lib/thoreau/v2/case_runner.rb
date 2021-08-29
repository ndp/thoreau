module Thoreau
  module V2
    class CaseRunner

      def initialize(context)
        @context = context
      end

      def logger
        @context.logger
      end

      def build_test_cases!
        logger.debug "build_test_cases!"

        cases = []

        @context.data.test_cases.each do |test_case|
          # kind = test_case[:kind]
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

      def run_test_cases! cases
        logger.info "# Test Suite #{@context.name}"
        cases.each do |c|
          if c.success?
            logger.info " OK     #{c.desc}"
          else
            logger.error "FAILED #{c.desc}, #{c.problem}"
          end
        end
      end

    end

  end
end
