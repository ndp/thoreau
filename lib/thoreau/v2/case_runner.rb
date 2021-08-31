module Thoreau
  module V2
    class CaseRunner

      def initialize(context)
        @context = context
      end

      def logger
        @context.logger
      end

      def run_test_cases! cases, skipped
        logger.info "  § #{@context.name} §"
        cases.each do |c|
          if c.ok?
            logger.info "  ✓ #{c.desc}"
          else
            logger.error "❓ #{c.desc}, #{c.problem}"
          end
        end
        logger.info (summary cases, skipped)
        logger.info ""

      end

      def summary cases, skipped
        ok     = cases.count(&:ok?)
        total  = cases.count
        failed = cases.count(&:failed?)
        if failed == 0
          "  ∴ All OK 👌🏾 #{skipped > 0 ? "#{skipped} skipped." : ""}"
        else
          " 🛑  #{failed} problem(s)            [#{ok} of #{total} OK#{skipped > 0 ? ", #{skipped} skipped" : ""}.]"
        end

      end

    end

  end
end
