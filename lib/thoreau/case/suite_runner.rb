module Thoreau
  module Case
    class SuiteRunner

      include Logging

      def initialize(name)
        @suite_name = name
      end

      def run_test_cases! cases, skipped
        legacy_results = LegacyResults.new(@suite_name)
        logger.info "  § #{@suite_name} §"
        cases.each do |c|


          legacy = c.expectation.legacy_output?
          if legacy
            if legacy_results.has_saved_legacy_expectation?(c)
              c.expectation = legacy_results.load_legacy_expectation c
            else
              logger.info "    no legacy data... running and saving."
              c.run
              legacy_results.save_legacy_expectation(c)
            end
          end

          c.run

          if c.ok?
            logger.info "  #{legacy ? '🔒' : '✓ ' } #{c.desc}"
          else
            logger.error "❓  #{c.desc}, #{c.problem}"
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
          " 🛑  #{failed} problem(s) detected.  [#{ok} of #{total} OK#{skipped > 0 ? ", #{skipped} skipped" : ""}.]"
        end

      end

    end

  end
end
