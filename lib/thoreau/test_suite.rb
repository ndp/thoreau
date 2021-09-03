require_relative './appendix'

module Thoreau
  class TestSuite

    attr_reader :name

    @@suites = []

    def initialize(data:, name:, focus:)
      @data  = data
      @name  = name
      @focus = focus
      @@suites << self

      appendix = Thoreau::Appendix.new(setups: @data.setups)

      @builder = Thoreau::Case::CaseBuilder.new action_block:  @data.action_block,
                                                appendix:      appendix,
                                                test_families: @data.test_families
    end

    def build_and_run
      cases = @builder.build_test_cases!

      runner = Thoreau::Case::SuiteRunner.new @name
      runner.run_test_cases! cases,
                             @builder.skipped_count # for reporting
    end

    def focused?
      @focus || @builder.any_focused?
    end

    def self.run_all!
      run_all = !@@suites.any?(&:focused?)
      @@suites.each do |suite|
        if suite.focused? || run_all
          suite.build_and_run
        else
          logger.info("Suite '#{suite.name}' skipped (unfocused)")
        end
      end
    end
  end
end
