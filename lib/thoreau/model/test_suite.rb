require 'active_support/core_ext/module/delegation'
require_relative './appendix'
require_relative '../case/multi_clan_case_builder'

module Thoreau
  module Model
    class TestSuite

      @@suites = []

      def initialize(data:, focus:)
        @data  = data
        @focus = focus
        @@suites << self

        # @builder = Thoreau::Case::CaseBuilder.new test_clan: @data.test_clan
        @builder = Thoreau::Case::MultiClanCaseBuilder.new test_clans: @data.test_clans
      end

      delegate :name, to: :@data

      def build_and_run
        logger.debug("## build_and_run")
        cases = @builder.build_test_cases!
        logger.debug("   ... built #{cases.size} cases")

        runner = Thoreau::Case::SuiteRunner.new @data.name
        runner.run_test_cases! cases,
                               @builder.skipped_count # for reporting
      end

      def focused?
        @focus || @builder.any_focused?
      end

      def self.run_all!
        logger.debug("# run_all! ############")
        run_all = !@@suites.any?(&:focused?)
        @@suites.each do |suite|
          if suite.focused? || run_all
            suite.build_and_run
          else
            logger.info("   Suite '#{suite.name}' skipped (unfocused)")
          end
        end
      end
    end
  end
end
