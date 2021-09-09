require 'thoreau/logging'
require 'thoreau/test_suite'
require 'thoreau/models/test_case'
require 'thoreau/models/test_clan'
require 'thoreau/case/case_builder'
require 'thoreau/case/suite_runner'
require 'thoreau/dsl/clan'
require 'thoreau/dsl/suite_context'
require 'thoreau/dsl/test_cases'
require 'thoreau/dsl/appendix'
require_relative './errors'

module Thoreau

  module DSL

    include Thoreau::Logging

    attr_reader :suite_data

    def test_suite name = nil, focus: false, &block
      logger.debug("# Processing keyword `test_suite`")

      appendix        = Models::Appendix.new
      top_level_clan_model = Thoreau::Models::TestClan.new name, appendix: appendix
      @suite_data     = TestSuiteData.new name, test_clan: top_level_clan_model, appendix: appendix

      # Evaluate all the top-level keywords: test_cases, appendix
      @suite_context = Thoreau::DSL::SuiteContext.new suite_data:      @suite_data,
                                                      test_clan_model: top_level_clan_model
      logger.debug("## Evaluating suite")
      @suite_context.instance_eval(&block)

      logger.debug("## Evaluating appendix block")
      appendix_block = @suite_data.appendix_block
      Thoreau::DSL::Appendix.new(@suite_data, &appendix_block) unless appendix_block.nil?

      logger.debug("## Evaluating test_cases blocks")
      @suite_data.test_cases_blocks.each do |name, cases_block|

        raise TestCasesAtMultipleLevelsError unless @suite_data.test_clans.first.empty?

        test_clan_model = Thoreau::Models::TestClan.new name,
                                                        appendix: appendix,
                                                        action_block: top_level_clan_model.action_block
        Thoreau::DSL::TestCases.new(test_clan_model, &cases_block)
        @suite_data.test_clans << test_clan_model
      end

      TestSuite.new(data: @suite_data, focus: focus)
    end

    def xtest_suite name = nil, &block
    end

    alias suite test_suite
    alias xsuite xtest_suite

    def test_suite! name = nil, &block
      test_suite name, focus: true, &block
    end

    alias suite! test_suite!

    include Thoreau::DSL::Clan

  end
end
