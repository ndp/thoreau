module Thoreau
  module Case
    class SuiteRunner

      include Logging

      def initialize(name)
        @suite_name = name
      end

      def run_test_cases! cases, skipped
        legacy_data = LegacyExpectedOutcomes.new(@suite_name)
        logger.info "     #{@suite_name}"
        cases.each do |c|

          legacy = c.expectation == :use_legacy_snapshot
          if legacy
            if !legacy_data.has_saved_for?(c) ||
              ENV['RESET_SNAPSHOTS']
              logger.info "     [#{ENV['RESET_SNAPSHOTS'] ? 'resetting' : 'saving'} legacy data]"
              c.run
              c.expectation = c.actual # by definition
              legacy_data.save!(c)
            else
              c.expectation = legacy_data.load_for c
            end
          end

          c.run

          if c.ok?
            logger.info "  #{legacy ? '▶️ ' : '✓ ' } #{c.desc.capitalize}"
          else
            logger.error "❓  #{c.desc.capitalize}, #{c.problem}"
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
          "  ∴  No problems detected 👌🏾 #{skipped > 0 ? "#{skipped} skipped." : ""}"
        else
          " 🛑  #{failed} problem(s) detected.  [#{ok} of #{total} OK#{skipped > 0 ? ", #{skipped} skipped" : ""}.]"
        end

      end

    end

  end
end
