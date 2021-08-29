module Thoreau
  module V2
    class CaseRunner

      def initialize(context)
        @context = context
      end

      def logger
        @context.logger
      end

      def run_test_cases! cases
        logger.info "# #{@context.name || "Test Suite"}"
        cases.each do |c|
          if c.success?
            logger.info " OK     #{c.desc}"
          else
            logger.error "FAILED #{c.desc}, #{c.problem}"
          end
        end
        logger.info "... #{cases.count(&:success?)} passed, #{cases.count(&:failed?)} failed."
        logger.info ""

      end

    end

  end
end
