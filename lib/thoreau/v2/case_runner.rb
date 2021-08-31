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
          if c.ok?
            logger.info " 👌🏾 #{c.desc}"
          else
            logger.error "⚠️  #{c.desc}, #{c.problem}"
          end
        end
        logger.info "... #{cases.count(&:ok?)} OK, #{cases.count(&:failed?)} problem(s)."
        logger.info ""

      end

    end

  end
end
