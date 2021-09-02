module Thoreau
  class TestSuite

    attr_reader :name
    attr_reader :logger

    @@suites = []

    def initialize(context:, logger:, name:, focus:)
      @context = context
      @logger  = logger
      @name    = name
      @focus   = focus
      @@suites << self

      @builder = Thoreau::Case::CaseBuilder.new @context.suite_data.test_families,
                                                @context.suite_data
    end

    def build_and_run
      cases = @builder.build_test_cases!

      runner = Thoreau::Case::CaseRunner.new @context
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
          suite.logger.info("Suite '#{suite.name}' skipped (unfocused)")
        end
      end
    end
  end
end
